package com.digitalstockmanager.infrastructure.secondary.persistence.repositories;

import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.entities.StandardStockItem;
import com.digitalstockmanager.domain.entities.PerishableStockItem;
import com.digitalstockmanager.domain.valueobjects.*;
import com.digitalstockmanager.infrastructure.secondary.persistence.jpa.SpringDataProductRepository;
import com.digitalstockmanager.infrastructure.secondary.persistence.jpa.StockItemJpaEntity;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class ProductRepositoryAdapter implements ProductCatalogRepository, ProductQueryRepository {

    private final SpringDataProductRepository jpaRepository;

    public ProductRepositoryAdapter(SpringDataProductRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    // --- Outbound Command Port Mapping (Domain -> JPA) ---
    @Override
    public void save(StockItem item) {
        LocalDate expiry = null;
        String type = "STANDARD";

        // Extract features based on polymorphic identity matching
        if (item instanceof PerishableStockItem perishable) {
            expiry = perishable.getExpiryDate().getValue().orElse(null);
            type = "PERISHABLE";
        }

        StockItemJpaEntity entity = new StockItemJpaEntity(
            item.getItemCode().getValue(),
            item.getItemName().getValue(),
            item.getPrice().getValue(),
            item.getQuantity().getValue(),
            item.getThreshold().getValue(),
            expiry,
            item.getStatus().name(),
            type
        );
        jpaRepository.save(entity);
    }

    @Override
    public Optional<StockItem> findByCode(ItemCode itemCode) {
        return jpaRepository.findById(itemCode.getValue()).map(this::toDomain);
    }

    // --- Outbound Query Port Mapping (Direct Optimized CQRS DTOs) ---
    @Override
    public Optional<ProductViewDto> fetchByCode(String itemCode) {
        return jpaRepository.findById(itemCode).map(this::toDto);
    }

    @Override
    public List<ProductViewDto> searchByKeywordOrSku(String query) {
        return jpaRepository.searchByKeywordOrSku(query).stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public List<ProductViewDto> fetchLowStockAlerts() {
        return jpaRepository.findLowStockAlerts().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public List<ProductViewDto> fetchExpiringProducts(int daysWindow) {
        LocalDate today = LocalDate.now();
        LocalDate windowEnd = today.plusDays(daysWindow);
        return jpaRepository.findExpiringProducts(today, windowEnd).stream().map(this::toDto).collect(Collectors.toList());
    }

    // Mappers
    private ProductViewDto toDto(StockItemJpaEntity entity) {
        return new ProductViewDto(
            entity.getItemCode(), entity.getItemName(), entity.getPrice(),
            entity.getQuantity(), entity.getThreshold(), entity.getExpiryDate(), entity.getStatus()
        );
    }

    private StockItem toDomain(StockItemJpaEntity entity) {
        ItemCode code = new ItemCode(entity.getItemCode());
        ItemName name = new ItemName(entity.getItemName());
        Price price = new Price(entity.getPrice());
        Quantity qty = new Quantity(entity.getQuantity());
        StockThreshold threshold = new StockThreshold(entity.getThreshold());

        StockItem item;

        // Polymorphic Reconstruction Strategy
        if ("PERISHABLE".equalsIgnoreCase(entity.getProductType())) {
            item = new PerishableStockItem(code, name, price, qty, threshold, new ExpiryDate(entity.getExpiryDate()));
        } else {
            item = new StandardStockItem(code, name, price, qty, threshold);
        }

        if ("DISCONTINUED".equals(entity.getStatus())) {
            item.discontinue();
        }
        return item;
    }
}
