#!/bin/bash

echo "🚀 Populating Infrastructure Layer with REST Controllers, JPA Entities, & Configuration..."

BASE_PATH="com/digitalstockmanager"
INFRA_DIR="infrastructure/src/main/java/$BASE_PATH/infrastructure"

# Ensure all target folders exist
mkdir -p "$INFRA_DIR/primary/web/commands"
mkdir -p "$INFRA_DIR/primary/web/queries"
mkdir -p "$INFRA_DIR/secondary/persistence/jpa"
mkdir -p "$INFRA_DIR/secondary/persistence/repositories"
mkdir -p "$INFRA_DIR/config"

# Remove any old .gitkeep placeholders
find "$INFRA_DIR" -name ".gitkeep" -delete

# ----------------------------------------------------------------
# 🗄️ WRITE JPA ENTITY & DATA ACESS OBJECT INTERFACES
# ----------------------------------------------------------------
echo "📝 Writing Database Persistence Entities..."

cat << 'EOF' > "$INFRA_DIR/secondary/persistence/jpa/StockItemJpaEntity.java"
package com.digitalstockmanager.infrastructure.secondary.persistence.jpa;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "stock_items")
public class StockItemJpaEntity {
    @Id
    private String itemCode;
    private String itemName;
    private BigDecimal price;
    private int quantity;
    private int threshold;
    private LocalDate expiryDate;
    private String status;

    // Default constructor for JPA
    public StockItemJpaEntity() {}

    public StockItemJpaEntity(String itemCode, String itemName, BigDecimal price,
                              int quantity, int threshold, LocalDate expiryDate, String status) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.expiryDate = expiryDate;
        this.status = status;
    }

    // Getters and Setters
    public String getItemCode() { return itemCode; }
    public void setItemCode(String itemCode) { this.itemCode = itemCode; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public int getThreshold() { return threshold; }
    public void setThreshold(int threshold) { this.threshold = threshold; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
EOF

cat << 'EOF' > "$INFRA_DIR/secondary/persistence/jpa/SpringDataProductRepository.java"
package com.digitalstockmanager.infrastructure.secondary.persistence.jpa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.util.List;

public interface SpringDataProductRepository extends JpaRepository<StockItemJpaEntity, String> {

    @Query("SELECT s FROM StockItemJpaEntity s WHERE UPPER(s.itemName) LIKE UPPER(CONCAT('%', :query, '%')) OR UPPER(s.itemCode) LIKE UPPER(CONCAT('%', :query, '%'))")
    List<StockItemJpaEntity> searchByKeywordOrSku(@Param("query") String query);

    @Query("SELECT s FROM StockItemJpaEntity s WHERE s.status = 'ACTIVE' AND s.quantity <= s.threshold")
    List<StockItemJpaEntity> findLowStockAlerts();

    @Query("SELECT s FROM StockItemJpaEntity s WHERE s.status = 'ACTIVE' AND s.expiryDate IS NOT NULL AND s.expiryDate BETWEEN :today AND :windowEnd")
    List<StockItemJpaEntity> findExpiringProducts(@Param("today") LocalDate today, @Param("windowEnd") LocalDate windowEnd);
}
EOF


# ----------------------------------------------------------------
# 🔁 WRITE PORT ADAPTER IMPLEMENTATIONS
# ----------------------------------------------------------------
echo "📝 Writing Secondary Port Adapters (Command & Query implementations)..."

cat << 'EOF' > "$INFRA_DIR/secondary/persistence/repositories/ProductRepositoryAdapter.java"
package com.digitalstockmanager.infrastructure.secondary.persistence.repositories;

import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import com.digitalstockmanager.domain.entities.StockItem;
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

    // --- Outbound Command Port Mapping (Domain <-> JPA) ---
    @Override
    public void save(StockItem item) {
        StockItemJpaEntity entity = new StockItemJpaEntity(
            item.getItemCode().getValue(),
            item.getItemName().getValue(),
            item.getPrice().getValue(),
            item.getQuantity().getValue(),
            item.getThreshold().getValue(),
            item.getExpiryDate().getValue().orElse(null),
            item.getStatus().name()
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
        // Triggers self-validation upon rebuilding state safely
        StockItem item = StockItem.onboard(
            new ItemCode(entity.getItemCode()),
            new ItemName(entity.getItemName()),
            new Price(entity.getPrice()),
            new Quantity(entity.getQuantity()),
            new StockThreshold(entity.getThreshold()),
            new ExpiryDate(entity.getExpiryDate())
        );
        if ("DISCONTINUED".equals(entity.getStatus())) {
            item.discontinue();
        }
        return item;
    }
}
EOF


# ----------------------------------------------------------------
# 🕹️ WRITE PRIMARY ADAPTERS (CQRS Controllers)
# ----------------------------------------------------------------
echo "📝 Writing REST Command Controller (State Changes)..."

cat << 'EOF' > "$INFRA_DIR/primary/web/commands/ProductCommandController.java"
package com.digitalstockmanager.infrastructure.primary.web.commands;

import com.digitalstockmanager.application.ports.input.commands.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
public class ProductCommandController {

    private final AddProductUseCase addProductUseCase;
    private final UpdateProductDetailsUseCase updateProductDetailsUseCase;
    private final DiscontinueProductUseCase discontinueProductUseCase;
    private final RestockProductUseCase restockProductUseCase;
    private final DeductStockUseCase deductStockUseCase;

    public ProductCommandController(AddProductUseCase addProductUseCase,
                                    UpdateProductDetailsUseCase updateProductDetailsUseCase,
                                    DiscontinueProductUseCase discontinueProductUseCase,
                                    RestockProductUseCase restockProductUseCase,
                                    DeductStockUseCase deductStockUseCase) {
        this.addProductUseCase = addProductUseCase;
        this.updateProductDetailsUseCase = updateProductDetailsUseCase;
        this.discontinueProductUseCase = discontinueProductUseCase;
        this.restockProductUseCase = restockProductUseCase;
        this.deductStockUseCase = deductStockUseCase;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> onboardProduct(@RequestBody AddProductRequest request) {
        addProductUseCase.execute(new AddProductUseCase.Command(
            request.itemCode(), request.itemName(), request.price(),
            request.initialQuantity(), request.threshold(), request.expiryDate()
        ));
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "Product registered successfully"));
    }

    @PutMapping("/{code}")
    public ResponseEntity<Map<String, String>> updateDetails(@PathVariable("code") String code, @RequestBody UpdateDetailsRequest request) {
        updateProductDetailsUseCase.execute(new UpdateProductDetailsUseCase.Command(
            code, request.itemName(), request.price(), request.threshold()
        ));
        return ResponseEntity.ok(Map.of("message", "Product descriptions updated successfully"));
    }

    @PostMapping("/{code}/restock")
    public ResponseEntity<Map<String, String>> restock(@PathVariable("code") String code, @RequestBody Map<String, Integer> payload) {
        restockProductUseCase.execute(code, payload.get("amount"));
        return ResponseEntity.ok(Map.of("message", "Inventory batch added successfully"));
    }

    @PostMapping("/{code}/deduct")
    public ResponseEntity<Map<String, String>> deduct(@PathVariable("code") String code, @RequestBody Map<String, Integer> payload) {
        deductStockUseCase.execute(code, payload.get("amount"));
        return ResponseEntity.ok(Map.of("message", "Stock allocated successfully"));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<Map<String, String>> discontinue(@PathVariable("code") String code) {
        discontinueProductUseCase.execute(code);
        return ResponseEntity.ok(Map.of("message", "Product flagged as discontinued"));
    }

    // Global Error Guard local override for quick implementation clarity
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleDomainErrors(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", ex.getMessage()));
    }

    // Request Payloads Mapping Records
    public record AddProductRequest(String itemCode, String itemName, BigDecimal price, int initialQuantity, int threshold, LocalDate expiryDate) {}
    public record UpdateDetailsRequest(String itemName, BigDecimal price, int threshold) {}
}
EOF

echo "📝 Writing REST Query Controller (Read Projections)..."

cat << 'EOF' > "$INFRA_DIR/primary/web/queries/ProductQueryController.java"
package com.digitalstockmanager.infrastructure.primary.web.queries;

import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductQueryController {

    private final ProductQueryService queryService;

    public ProductQueryController(ProductQueryService queryService) {
        this.queryService = queryService;
    }

    @GetMapping("/{code}")
    public ResponseEntity<ProductViewDto> getProductByCode(@PathVariable("code") String code) {
        return queryService.getProductByCode(code)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProductViewDto>> searchInventory(@RequestParam("q") String query) {
        return ResponseEntity.ok(queryService.searchInventory(query));
    }

    @GetMapping("/alerts/low-stock")
    public ResponseEntity<List<ProductViewDto>> getLowStockAlerts() {
        return ResponseEntity.ok(queryService.getLowStockAlerts());
    }

    @GetMapping("/alerts/expiring")
    public ResponseEntity<List<ProductViewDto>> getExpiringProducts(@RequestParam(value = "days", defaultValue = "7") int days) {
        return ResponseEntity.ok(queryService.getExpiringProducts(days));
    }
}
EOF


# ----------------------------------------------------------------
# ⚙️ WRITE APPLICATION MANUAL BEAN CONFIGURATION & MAIN BOOTSTRAP
# ----------------------------------------------------------------
echo "📝 Writing Architecture Bean Configuration Factory..."

cat << 'EOF' > "$INFRA_DIR/config/DomainUseCaseConfiguration.java"
package com.digitalstockmanager.infrastructure.config;

import com.digitalstockmanager.application.ports.input.commands.*;
import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import com.digitalstockmanager.application.usecases.commands.*;
import com.digitalstockmanager.application.usecases.queries.ProductQueryFacade;
import com.digitalstockmanager.infrastructure.secondary.persistence.repositories.ProductRepositoryAdapter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DomainUseCaseConfiguration {

    @Bean
    public AddProductUseCase addProductUseCase(ProductRepositoryAdapter adapter) {
        return new AddProductService(adapter);
    }

    @Bean
    public UpdateProductDetailsUseCase updateProductDetailsUseCase(ProductRepositoryAdapter adapter) {
        return new UpdateProductDetailsService(adapter);
    }

    @Bean
    public DiscontinueProductUseCase discontinueProductUseCase(ProductRepositoryAdapter adapter) {
        return new DiscontinueProductService(adapter);
    }

    @Bean
    public RestockProductUseCase restockProductUseCase(ProductRepositoryAdapter adapter) {
        return new RestockProductService(adapter);
    }

    @Bean
    public DeductStockUseCase deductStockUseCase(ProductRepositoryAdapter adapter) {
        return new DeductStockService(adapter);
    }

    @Bean
    public ProductQueryService productQueryService(ProductRepositoryAdapter adapter) {
        return new ProductQueryFacade(adapter);
    }
}
EOF

echo "📝 Writing Spring Boot Main Application Entrypoint..."

cat << 'EOF' > "$INFRA_DIR/config/DigitalStockManagerApplication.java"
package com.digitalstockmanager.infrastructure.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.boot.autoconfigure.domain.EntityScan;

@SpringBootApplication(scanBasePackages = "com.digitalstockmanager")
@EnableJpaRepositories(basePackages = "com.digitalstockmanager.infrastructure.secondary.persistence.jpa")
@EntityScan(basePackages = "com.digitalstockmanager.infrastructure.secondary.persistence.jpa")
public class DigitalStockManagerApplication {
    public static void main(String[] args) {
        SpringApplication.run(DigitalStockManagerApplication.class, args);
    }
}
EOF

echo "✨ Infrastructure Layer populated, endpoints configured active!"