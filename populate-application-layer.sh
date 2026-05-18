#!/bin/bash

echo "🚀 Populating Application Layer with CQRS Use Cases & Ports..."

BASE_PATH="com/digitalstockmanager"
APP_DIR="application/src/main/java/$BASE_PATH/application"

# Ensure all application target folders exist
mkdir -p "$APP_DIR/ports/input/commands"
mkdir -p "$APP_DIR/ports/input/queries"
mkdir -p "$APP_DIR/ports/output/commands"
mkdir -p "$APP_DIR/ports/output/queries"
mkdir -p "$APP_DIR/usecases/commands"
mkdir -p "$APP_DIR/usecases/queries"

# Remove any old .gitkeep placeholders in application directories
find "$APP_DIR" -name ".gitkeep" -delete

# ----------------------------------------------------------------
# 📦 WRITE DTOs (Data Transfer Objects) FOR QUERIES
# ----------------------------------------------------------------
echo "📝 Writing Read-Model DTOs..."

cat << 'EOF' > "$APP_DIR/usecases/queries/ProductViewDto.java"
package com.digitalstockmanager.application.usecases.queries;

import java.math.BigDecimal;
import java.time.LocalDate;

public class ProductViewDto {
    private final String itemCode;
    private final String itemName;
    private final BigDecimal price;
    private final int quantity;
    private final int threshold;
    private final LocalDate expiryDate;
    private final String status;

    public ProductViewDto(String itemCode, String itemName, BigDecimal price,
                          int quantity, int threshold, LocalDate expiryDate, String status) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.expiryDate = expiryDate;
        this.status = status;
    }

    public String getItemCode() { return itemCode; }
    public String getItemName() { return itemName; }
    public BigDecimal getPrice() { return price; }
    public int getQuantity() { return quantity; }
    public int getThreshold() { return threshold; }
    public LocalDate getExpiryDate() { return expiryDate; }
    public String getStatus() { return status; }
}
EOF


# ----------------------------------------------------------------
# 🚪 WRITE OUTBOUND PORTS (SPI - Service Provider Interfaces)
# ----------------------------------------------------------------
echo "📝 Writing Outbound Ports (SPI)..."

# Command State Repository
cat << 'EOF' > "$APP_DIR/ports/output/commands/ProductCatalogRepository.java"
package com.digitalstockmanager.application.ports.output;

import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.valueobjects.ItemCode;
import java.util.Optional;

public interface ProductCatalogRepository {
    void save(StockItem stockItem);
    Optional<StockItem> findByCode(ItemCode itemCode);
}
EOF

# Query Read Repository (CQRS Optimization Pathway)
cat << 'EOF' > "$APP_DIR/ports/output/queries/ProductQueryRepository.java"
package com.digitalstockmanager.application.ports.output;

import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import java.util.List;
import java.util.Optional;

public interface ProductQueryRepository {
    Optional<ProductViewDto> fetchByCode(String itemCode);
    List<ProductViewDto> searchByKeywordOrSku(String query);
    List<ProductViewDto> fetchLowStockAlerts();
    List<ProductViewDto> fetchExpiringProducts(int daysWindow);
}
EOF


# ----------------------------------------------------------------
# 🚪 WRITE INBOUND PORTS (API - Use Case Contracts)
# ----------------------------------------------------------------
echo "📝 Writing Inbound Command Ports..."

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
        LocalDate expiryDate
    ) {}
}
EOF

cat << 'EOF' > "$APP_DIR/ports/input/commands/UpdateProductDetailsUseCase.java"
package com.digitalstockmanager.application.ports.input.commands;

import java.math.BigDecimal;

public interface UpdateProductDetailsUseCase {
    void execute(Command command);

    record Command(
        String itemCode,
        String newName,
        BigDecimal newPrice,
        int newThreshold
    ) {}
}
EOF

cat << 'EOF' > "$APP_DIR/ports/input/commands/DiscontinueProductUseCase.java"
package com.digitalstockmanager.application.ports.input.commands;

public interface DiscontinueProductUseCase {
    void execute(String itemCode);
}
EOF

cat << 'EOF' > "$APP_DIR/ports/input/commands/RestockProductUseCase.java"
package com.digitalstockmanager.application.ports.input.commands;

public interface RestockProductUseCase {
    void execute(String itemCode, int quantityAmount);
}
EOF

cat << 'EOF' > "$APP_DIR/ports/input/commands/DeductStockUseCase.java"
package com.digitalstockmanager.application.ports.input.commands;

public interface DeductStockUseCase {
    void execute(String itemCode, int quantityAmount);
}
EOF

echo "📝 Writing Inbound Query Ports..."

cat << 'EOF' > "$APP_DIR/ports/input/queries/ProductQueryService.java"
package com.digitalstockmanager.application.ports.input.queries;

import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import java.util.List;
import java.util.Optional;

public interface ProductQueryService {
    Optional<ProductViewDto> getProductByCode(String itemCode);
    List<ProductViewDto> searchInventory(String query);
    List<ProductViewDto> getLowStockAlerts();
    List<ProductViewDto> getExpiringProducts(int daysWindow);
}
EOF


# ----------------------------------------------------------------
# ⚙️ WRITE COMMAND USE CASE HANDLERS
# ----------------------------------------------------------------
echo "📝 Writing Command Use Case Implementations..."

cat << 'EOF' > "$APP_DIR/usecases/commands/AddProductService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.AddProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
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
            throw new DomainException("Product SKU identity registration clash. Code already exists: " + cmd.itemCode());
        }

        StockItem item = StockItem.onboard(
            code,
            new ItemName(cmd.itemName()),
            new Price(cmd.price()),
            new Quantity(cmd.initialQuantity()),
            new StockThreshold(cmd.threshold()),
            new ExpiryDate(cmd.expiryDate())
        );

        repository.save(item);
    }
}
EOF

cat << 'EOF' > "$APP_DIR/usecases/commands/UpdateProductDetailsService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.UpdateProductDetailsUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.*;

public class UpdateProductDetailsService implements UpdateProductDetailsUseCase {
    private final ProductCatalogRepository repository;

    public UpdateProductDetailsService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(Command cmd) {
        StockItem item = repository.findByCode(new ItemCode(cmd.itemCode()))
                .orElseThrow(() -> new DomainException("Product modification failed. Item not found: " + cmd.itemCode()));

        item.updateDetails(
            new ItemName(cmd.newName()),
            new Price(cmd.newPrice()),
            new StockThreshold(cmd.newThreshold())
        );

        repository.save(item);
    }
}
EOF

cat << 'EOF' > "$APP_DIR/usecases/commands/DiscontinueProductService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.DiscontinueProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.ItemCode;

public class DiscontinueProductService implements DiscontinueProductUseCase {
    private final ProductCatalogRepository repository;

    public DiscontinueProductService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(String itemCode) {
        StockItem item = repository.findByCode(new ItemCode(itemCode))
                .orElseThrow(() -> new DomainException("Retirement failed. StockItem target not found: " + itemCode));

        item.discontinue();
        repository.save(item);
    }
}
EOF

cat << 'EOF' > "$APP_DIR/usecases/commands/RestockProductService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.RestockProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.ItemCode;
import com.digitalstockmanager.domain.valueobjects.Quantity;

public class RestockProductService implements RestockProductUseCase {
    private final ProductCatalogRepository repository;

    public RestockProductService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(String itemCode, int quantityAmount) {
        StockItem item = repository.findByCode(new ItemCode(itemCode))
                .orElseThrow(() -> new DomainException("Restock operation failed. Item missing: " + itemCode));

        item.restock(new Quantity(quantityAmount));
        repository.save(item);

        // Architecture Note: You can dispatch your ProductRestocked Domain Event right here
        // to propagate transactional events outwards into your Audit context infrastructure logs!
    }
}
EOF

cat << 'EOF' > "$APP_DIR/usecases/commands/DeductStockService.java"
package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.DeductStockUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.ItemCode;
import com.digitalstockmanager.domain.valueobjects.Quantity;

public class DeductStockService implements DeductStockUseCase {
    private final ProductCatalogRepository repository;

    public DeductStockService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(String itemCode, int quantityAmount) {
        StockItem item = repository.findByCode(new ItemCode(itemCode))
                .orElseThrow(() -> new DomainException("Fulfillment subtraction failed. Item missing: " + itemCode));

        // Critical Domain Invariant is safely run inside the core aggregate root entity itself
        item.deduct(new Quantity(quantityAmount));
        repository.save(item);
    }
}
EOF


# ----------------------------------------------------------------
# ⚙️ WRITE QUERY USE CASE HANDLER (CQRS Pathway Implementation)
# ----------------------------------------------------------------
echo "📝 Writing Query Use Case Implementations..."

cat << 'EOF' > "$APP_DIR/usecases/queries/ProductQueryFacade.java"
package com.digitalstockmanager.application.usecases.queries;

import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import java.util.List;
import java.util.Optional;

public class ProductQueryFacade implements ProductQueryService {
    private final ProductQueryRepository queryRepository;

    public ProductQueryFacade(ProductQueryRepository queryRepository) {
        this.queryRepository = queryRepository;
    }

    @Override
    public Optional<ProductViewDto> getProductByCode(String itemCode) {
        return queryRepository.fetchByCode(itemCode);
    }

    @Override
    public List<ProductViewDto> searchInventory(String query) {
        return queryRepository.searchByKeywordOrSku(query);
    }

    @Override
    public List<ProductViewDto> getLowStockAlerts() {
        return queryRepository.fetchLowStockAlerts();
    }

    @Override
    public List<ProductViewDto> getExpiringProducts(int daysWindow) {
        return queryRepository.fetchExpiringProducts(daysWindow);
    }
}
EOF

echo "✨ Application Layer Usecases & CQRS contracts compiled perfectly!"