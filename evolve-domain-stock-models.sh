#!/bin/bash

echo "🚀 Evolving Domain & Application Layers using Stock-centric naming strategies..."

BASE_PATH="com/digitalstockmanager"
DOM_DIR="domain/src/main/java/$BASE_PATH/domain"
APP_DIR="application/src/main/java/$BASE_PATH/application"
INFRA_DIR="infrastructure/src/main/java/$BASE_PATH/infrastructure"

# Ensure models target folder exists
mkdir -p "$DOM_DIR/models"

# Clean out any old Item-named strategy files if they exist to prevent build conflicts
rm -f "$DOM_DIR/models/ItemType.java"
rm -f "$DOM_DIR/models/GeneralItemType.java"
rm -f "$DOM_DIR/models/PerishableItemType.java"

# ----------------------------------------------------------------
# 🧩 1. WRITE NEW STOCK STRATEGY & VARIANTS
# ----------------------------------------------------------------
echo "📝 Writing Sealed StockType strategies..."

cat << 'EOF' > "$DOM_DIR/models/StockType.java"
package com.digitalstockmanager.domain.models;

import java.time.LocalDate;

public sealed interface StockType permits GeneralStock, PerishableStock {
    boolean isPerishable();
    boolean isExpired(LocalDate systemDate);
}
EOF

cat << 'EOF' > "$DOM_DIR/models/GeneralStock.java"
package com.digitalstockmanager.domain.models;

import java.time.LocalDate;

public final class GeneralStock implements StockType {
    @Override public boolean isPerishable() { return false; }
    @Override public boolean isExpired(LocalDate systemDate) { return false; } // General assets never spoil
}
EOF

cat << 'EOF' > "$DOM_DIR/models/PerishableStock.java"
package com.digitalstockmanager.domain.models;

import com.digitalstockmanager.domain.valueobjects.ExpiryDate;
import java.time.LocalDate;
import java.util.Objects;

public final class PerishableStock implements StockType {
    private final ExpiryDate expiryDate;

    public PerishableStock(ExpiryDate expiryDate) {
        this.expiryDate = Objects.requireNonNull(expiryDate, "Perishable stock explicitly requires an expiration date.");
        if (expiryDate.getValue().isEmpty()) {
            throw new IllegalArgumentException("Perishable stock cannot have an empty expiration stamp.");
        }
    }

    public ExpiryDate getExpiryDate() { return expiryDate; }

    @Override public boolean isPerishable() { return true; }

    @Override
    public boolean isExpired(LocalDate systemDate) {
        return expiryDate.getValue()
                .map(date -> date.isBefore(systemDate) || date.isEqual(systemDate))
                .orElse(false);
    }
}
EOF

# ----------------------------------------------------------------
# 📦 2. REWRITE STOCKITEM AGGREGATE ROOT USING COMPOSITION
# ----------------------------------------------------------------
echo "📝 Updating StockItem Aggregate Root with StockType Strategy..."

cat << 'EOF' > "$DOM_DIR/entities/StockItem.java"
package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.models.*;
import com.digitalstockmanager.domain.valueobjects.*;
import java.time.LocalDate;

public class StockItem {
    private final ItemCode itemCode;
    private ItemName itemName;
    private Price price;
    private Quantity quantity;
    private StockThreshold threshold;
    private final StockType stockType; // Polymorphic Strategy Composition
    private StockStatus status;

    public enum StockStatus { ACTIVE, DISCONTINUED }

    private StockItem(ItemCode itemCode, ItemName itemName, Price price, Quantity quantity, StockThreshold threshold, StockType stockType) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.stockType = stockType;
        this.status = StockStatus.ACTIVE;
    }

    public static StockItem onboard(ItemCode itemCode, ItemName itemName, Price price, Quantity quantity, StockThreshold threshold, StockType stockType) {
        return new StockItem(itemCode, itemName, price, quantity, threshold, stockType);
    }

    public void restock(Quantity amount) {
        if (status == StockStatus.DISCONTINUED) {
            throw new DomainException("Restock operation blocked. Item [" + itemCode.getValue() + "] has been retired.");
        }
        if (stockType.isExpired(LocalDate.now())) {
            throw new DomainException("Restock violation! Cannot restock expired perishable goods.");
        }
        this.quantity = new Quantity(this.quantity.getValue() + amount.getValue());
    }

    public void deduct(Quantity amount) {
        if (status == StockStatus.DISCONTINUED) {
            throw new DomainException("Stock assignment failure. Item is currently marked as archived/discontinued.");
        }
        if (this.quantity.getValue() < amount.getValue()) {
            throw new DomainException("Insufficient stock for item [" + itemCode.getValue() + "]. Available: " + this.quantity.getValue() + ", Requested: " + amount.getValue());
        }
        this.quantity = new Quantity(this.quantity.getValue() - amount.getValue());
    }

    public void updateDetails(ItemName newName, Price newPrice, StockThreshold newThreshold) {
        this.itemName = newName;
        this.price = newPrice;
        this.threshold = newThreshold;
    }

    public void discontinue() { this.status = StockStatus.DISCONTINUED; }

    public ItemCode getItemCode() { return itemCode; }
    public ItemName getItemName() { return itemName; }
    public Price getPrice() { return price; }
    public Quantity getQuantity() { return quantity; }
    public StockThreshold getThreshold() { return threshold; }
    public StockType getStockType() { return stockType; }
    public StockStatus getStatus() { return status; }
}
EOF

# ----------------------------------------------------------------
# 🚪 3. UPDATE APPLICATION COMMAND INTERFACE
# ----------------------------------------------------------------
echo "📝 Updating Application Layer Inbound Port payloads..."

cat << 'EOF' > "$APP_DIR/ports/input/commands/AddProductUseCase.java"
package com.digitalstockmanager.application.ports.input.commands;

import java.math.BigDecimal;
import java.time.LocalDate;

public interface AddProductUseCase {
    void execute(Command command);

    record Command(
        String itemCode,
        String itemName,
        BigDecimal price,
        int initialQuantity,
        int threshold,
        String itemCategory, // "GENERAL" or "PERISHABLE"
        LocalDate expiryDate
    ) {}
}
EOF

# ----------------------------------------------------------------
# ⚙️ 4. UPDATE APPLICATION COMMAND SERVICE
# ----------------------------------------------------------------
echo "📝 Updating AddProductService strategy router..."

cat << 'EOF' > "$APP_DIR/usecases/commands/AddProductService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.AddProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.models.*;
import com.digitalstockmanager.domain.valueobjects.*;

public class AddProductService implements AddProductUseCase {
    private final ProductCatalogRepository repository;

    public AddProductService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(Command cmd) {
        ItemCode code = new ItemCode(cmd.itemCode());
        if (repository.findByCode(code).isPresent()) {
            throw new DomainException("Product SKU registration collision. Code already exists: " + cmd.itemCode());
        }

        // Mapping to our cleanly named domain strategies
        StockType resolvedType = switch (cmd.itemCategory().toUpperCase()) {
            case "PERISHABLE" -> new PerishableStock(new ExpiryDate(cmd.expiryDate()));
            case "GENERAL" -> new GeneralStock();
            default -> throw new DomainException("Unsupported stock category allocation token: " + cmd.itemCategory());
        };

        StockItem item = StockItem.onboard(
            code,
            new ItemName(cmd.itemName()),
            new Price(cmd.price()),
            new Quantity(cmd.initialQuantity()),
            new StockThreshold(cmd.threshold()),
            resolvedType
        );

        repository.save(item);
    }
}
EOF

# ----------------------------------------------------------------
# 🗄️ 5. UPDATE INFRASTRUCTURE DATA PERSISTENCE LAYER MAPPERS
# ----------------------------------------------------------------
echo "📝 Re-wiring Infrastructure JPA Entity Serialization Mappers..."

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
    @Id private String itemCode;
    private String itemName;
    private BigDecimal price;
    private int quantity;
    private int threshold;
    private String itemCategory; // Stores database discriminator strategy token: "GENERAL" or "PERISHABLE"
    private LocalDate expiryDate;
    private String status;

    public StockItemJpaEntity() {}

    public StockItemJpaEntity(String itemCode, String itemName, BigDecimal price, int quantity,
                              int threshold, String itemCategory, LocalDate expiryDate, String status) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.itemCategory = itemCategory;
        this.expiryDate = expiryDate;
        this.status = status;
    }

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
    public String getItemCategory() { return itemCategory; }
    public void setItemCategory(String itemCategory) { this.itemCategory = itemCategory; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public void setExpiryDate(LocalDate expiryDate) { this.expiryDate = expiryDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
EOF

cat << 'EOF' > "$INFRA_DIR/secondary/persistence/repositories/ProductRepositoryAdapter.java"
package com.digitalstockmanager.infrastructure.secondary.persistence.repositories;

import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.models.*;
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

    @Override
    public void save(StockItem item) {
        String category = item.getStockType().isPerishable() ? "PERISHABLE" : "GENERAL";
        LocalDate expiry = item.getStockType() instanceof PerishableStock perishable
                ? perishable.getExpiryDate().getValue().orElse(null)
                : null;

        StockItemJpaEntity entity = new StockItemJpaEntity(
            item.getItemCode().getValue(),
            item.getItemName().getValue(),
            item.getPrice().getValue(),
            item.getQuantity().getValue(),
            item.getThreshold().getValue(),
            category,
            expiry,
            item.getStatus().name()
        );
        jpaRepository.save(entity);
    }

    @Override
    public Optional<StockItem> findByCode(ItemCode itemCode) {
        return jpaRepository.findById(itemCode.getValue()).map(this::toDomain);
    }

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

    private ProductViewDto toDto(StockItemJpaEntity entity) {
        String customName = "[" + entity.getItemCategory() + "] " + entity.getItemName();
        return new ProductViewDto(
            entity.getItemCode(), customName, entity.getPrice(),
            entity.getQuantity(), entity.getThreshold(), entity.getExpiryDate(), entity.getStatus()
        );
    }

    private StockItem toDomain(StockItemJpaEntity entity) {
        StockType resolvedType = "PERISHABLE".equalsIgnoreCase(entity.getItemCategory())
                ? new PerishableStock(new ExpiryDate(entity.getExpiryDate()))
                : new GeneralStock();

        StockItem item = StockItem.onboard(
            new ItemCode(entity.getItemCode()),
            new ItemName(entity.getItemName()),
            new Price(entity.getPrice()),
            new Quantity(entity.getQuantity()),
            new StockThreshold(entity.getThreshold()),
            resolvedType
        );
        if ("DISCONTINUED".equals(entity.getStatus())) {
            item.discontinue();
        }
        return item;
    }
}
EOF

# ----------------------------------------------------------------
# 📱 6. PRESERVE AND OVERWRITE USER INTERFACE HOOKS
# ----------------------------------------------------------------
echo "📝 Refreshing Dashboard static resource UI hooks..."

# Check if selector already exists, if not, append it seamlessly.
if ! grep -q "itemCategory" infrastructure/src/main/resources/static/index.html; then
    sed -i '/<div class="form-group" id="initialQtyContainer">/i \                    <div class="form-group">\n                        <label for="itemCategory">Inventory Product Profile Category<\/label>\n                        <select id="itemCategory" class="form-control" onchange="toggleExpiryFieldVisibility()">\n                            <option value="GENERAL">General Commodity / Durable Asset<\/option>\n                            <option value="PERISHABLE">Perishable Goods / Food / Medicine<\/option>\n                        <\/select>\n                    <\/div>' infrastructure/src/main/resources/static/index.html
    sed -i '/function executeProductCommand() {/i \        function toggleExpiryFieldVisibility() {\n            const cat = document.getElementById("itemCategory").value;\n            document.getElementById("expiryContainer").style.display = (cat === "GENERAL") ? "none" : "block";\n        }\n' infrastructure/src/main/resources/static/index.html
    sed -i 's/threshold: parseInt(document.getElementById('\''threshold'\'').value)/threshold: parseInt(document.getElementById('\''threshold'\'').value),\n                itemCategory: document.getElementById('\''itemCategory'\'').value/g' infrastructure/src/main/resources/static/index.html
    sed -i '/document.getElementById('\''productForm'\'').reset();/a \            toggleExpiryFieldVisibility();' infrastructure/src/main/resources/static/index.html
fi

echo "✨ System strategy compilation matrix using StockType models successfully completed!"