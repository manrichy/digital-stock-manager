#!/bin/bash

echo "🚀 Step 1: Initializing Hexagonal Architecture with CQRS Directories..."

# Clean up root single-module src artifact if it exists
rm -rf src

BASE_PATH="com/digitalstockmanager"

# ----------------------------------------------------------------
# DOMAIN MODULE LAYER DIRECTORIES
# ----------------------------------------------------------------
echo "📁 Building Domain Module Packages..."
DOMAIN_DIR="domain/src/main/java/$BASE_PATH/domain"

mkdir -p "$DOMAIN_DIR/entities"
mkdir -p "$DOMAIN_DIR/valueobjects"
mkdir -p "$DOMAIN_DIR/exceptions"
mkdir -p "$DOMAIN_DIR/events"


# ----------------------------------------------------------------
# APPLICATION MODULE LAYER DIRECTORIES
# ----------------------------------------------------------------
echo "📁 Building Application Module Packages..."
APP_DIR="application/src/main/java/$BASE_PATH/application"

mkdir -p "$APP_DIR/usecases/commands"
mkdir -p "$APP_DIR/ports/input/commands"
mkdir -p "$APP_DIR/ports/output/commands"
mkdir -p "$APP_DIR/usecases/queries"
mkdir -p "$APP_DIR/ports/input/queries"
mkdir -p "$APP_DIR/ports/output/queries"

touch "$APP_DIR/usecases/commands/.gitkeep"
touch "$APP_DIR/usecases/queries/.gitkeep"


# ----------------------------------------------------------------
# INFRASTRUCTURE MODULE LAYER DIRECTORIES
# ----------------------------------------------------------------
echo "📁 Building Infrastructure Module Packages..."
INFRA_DIR="infrastructure/src/main/java/$BASE_PATH/infrastructure"

mkdir -p "$INFRA_DIR/primary/web/commands"
mkdir -p "$INFRA_DIR/primary/web/queries"
mkdir -p "$INFRA_DIR/primary/eventlisteners"
mkdir -p "$INFRA_DIR/secondary/persistence/jpa"
mkdir -p "$INFRA_DIR/secondary/persistence/repositories"
mkdir -p "$INFRA_DIR/secondary/clients"
mkdir -p "$INFRA_DIR/config"

touch "$INFRA_DIR/primary/web/commands/.gitkeep"
touch "$INFRA_DIR/secondary/persistence/repositories/.gitkeep"


# ----------------------------------------------------------------
# WRITE JAVA DOMAIN FILES
# ----------------------------------------------------------------
echo "📝 Writing Domain Exceptions..."

cat << 'EOF' > "$DOMAIN_DIR/exceptions/DomainException.java"
package com.digitalstockmanager.domain.exceptions;

public class DomainException extends RuntimeException {
    public DomainException(String message) {
        super(message);
    }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/exceptions/InsufficientStockException.java"
package com.digitalstockmanager.domain.exceptions;

public class InsufficientStockException extends DomainException {
    public InsufficientStockException(String itemCode, int current, int requested) {
        super(String.format("Insufficient stock for item [%s]. Available: %d, Requested: %d",
                itemCode, current, requested));
    }
}
EOF

echo "📝 Writing Domain Value Objects..."

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/ProductStatus.java"
package com.digitalstockmanager.domain.valueobjects;

public enum ProductStatus {
    ACTIVE,
    DISCONTINUED
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/ItemCode.java"
package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class ItemCode {
    private final String value;

    public ItemCode(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new DomainException("Item code cannot be null or empty.");
        }
        String cleaned = value.trim().toUpperCase();
        if (!cleaned.matches("^[A-Z0-9\\-]+$")) {
            throw new DomainException("Item code must be alphanumeric (hyphens allowed).");
        }
        this.value = cleaned;
    }

    public String getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.equals(((ItemCode) o).value);
    }

    @Override
    public int hashCode() { return value.hashCode(); }

    @Override
    public String toString() { return value; }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/ItemName.java"
package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class ItemName {
    private final String value;

    public ItemName(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new DomainException("Item name cannot be null or empty.");
        }
        if (value.trim().length() > 100) {
            throw new DomainException("Item name cannot exceed 100 characters.");
        }
        this.value = value.trim();
    }

    public String getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.equals(((ItemName) o).value);
    }

    @Override
    public int hashCode() { return value.hashCode(); }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/Price.java"
package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;
import java.math.BigDecimal;

public final class Price {
    private final BigDecimal value;

    public Price(BigDecimal value) {
        if (value == null) {
            throw new DomainException("Price cannot be null.");
        }
        if (value.compareTo(BigDecimal.ZERO) < 0) {
            throw new DomainException("Price cannot be negative.");
        }
        this.value = value;
    }

    public BigDecimal getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.compareTo(((Price) o).value) == 0;
    }

    @Override
    public int hashCode() { return value.hashCode(); }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/Quantity.java"
package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class Quantity {
    private final int value;

    public Quantity(int value) {
        if (value < 0) {
            throw new DomainException("Quantity cannot be negative.");
        }
        this.value = value;
    }

    public int getValue() { return value; }

    public Quantity add(Quantity other) {
        return new Quantity(this.value + other.value);
    }

    public Quantity subtract(Quantity other) {
        return new Quantity(this.value - other.value);
    }

    public boolean isGreaterThanOrEqualTo(Quantity other) {
        return this.value >= other.value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value == ((Quantity) o).value;
    }

    @Override
    public int hashCode() { return value; }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/StockThreshold.java"
package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class StockThreshold {
    private final int value;

    public StockThreshold(int value) {
        if (value < 0) {
            throw new DomainException("Stock threshold cannot be negative.");
        }
        this.value = value;
    }

    public int getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value == ((StockThreshold) o).value;
    }

    @Override
    public int hashCode() { return value; }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/valueobjects/ExpiryDate.java"
package com.digitalstockmanager.domain.valueobjects;

import java.time.LocalDate;
import java.util.Optional;

public final class ExpiryDate {
    private final LocalDate value;

    public ExpiryDate(LocalDate value) {
        this.value = value;
    }

    public Optional<LocalDate> getValue() {
        return Optional.ofNullable(value);
    }

    public boolean isExpiredAsOf(LocalDate date) {
        return value != null && value.isBefore(date);
    }

    public boolean isExpiringWithinWindow(LocalDate start, LocalDate end) {
        if (value == null) return false;
        return !value.isBefore(start) && !value.isAfter(end);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ExpiryDate that = (ExpiryDate) o;
        return (value == null && that.value == null) || (value != null && value.equals(that.value));
    }

    @Override
    public int hashCode() {
        return value != null ? value.hashCode() : 0;
    }
}
EOF

echo "📝 Writing Polymorphic Aggregate Root (StockItem)..."

cat << 'EOF' > "$DOMAIN_DIR/entities/StockItem.java"
package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.exceptions.InsufficientStockException;
import com.digitalstockmanager.domain.valueobjects.*;

public abstract class StockItem {
    private final ItemCode itemCode;
    private ItemName itemName;
    private Price price;
    private Quantity quantity;
    private StockThreshold threshold;
    private ProductStatus status;

    protected StockItem(ItemCode itemCode, ItemName itemName, Price price,
                        Quantity quantity, StockThreshold threshold) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.status = ProductStatus.ACTIVE;
    }

    public void restock(Quantity amount) {
        guardAgainstDiscontinued();
        this.quantity = this.quantity.add(amount);
    }

    public void deduct(Quantity amount) {
        guardAgainstDiscontinued();
        if (!this.quantity.isGreaterThanOrEqualTo(amount)) {
            throw new InsufficientStockException(this.itemCode.getValue(), this.quantity.getValue(), amount.getValue());
        }
        this.quantity = this.quantity.subtract(amount);
    }

    public void updateDetails(ItemName newName, Price newPrice, StockThreshold newThreshold) {
        guardAgainstDiscontinued();
        this.itemName = newName;
        this.price = newPrice;
        this.threshold = newThreshold;
    }

    public void discontinue() {
        this.status = ProductStatus.DISCONTINUED;
    }

    public boolean isLowStock() {
        return this.status == ProductStatus.ACTIVE && this.quantity.getValue() <= this.threshold.getValue();
    }

    protected void guardAgainstDiscontinued() {
        if (this.status == ProductStatus.DISCONTINUED) {
            throw new DomainException("Cannot modify stock data or quantities on a discontinued item.");
        }
    }

    public ItemCode getItemCode() { return itemCode; }
    public ItemName getItemName() { return itemName; }
    public Price getPrice() { return price; }
    public Quantity getQuantity() { return quantity; }
    public StockThreshold getThreshold() { return threshold; }
    public ProductStatus getStatus() { return status; }
}
EOF

echo "📝 Writing Concrete Polymorphic Stock Subclasses..."

cat << 'EOF' > "$DOMAIN_DIR/entities/StandardStockItem.java"
package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.valueobjects.*;

public class StandardStockItem extends StockItem {

    public StandardStockItem(ItemCode itemCode, ItemName itemName, Price price,
                             Quantity quantity, StockThreshold threshold) {
        super(itemCode, itemName, price, quantity, threshold);
    }
}
EOF

cat << 'EOF' > "$DOMAIN_DIR/entities/PerishableStockItem.java"
package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.valueobjects.*;
import java.time.LocalDate;

public class PerishableStockItem extends StockItem {
    private final ExpiryDate expiryDate;

    public PerishableStockItem(ItemCode itemCode, ItemName itemName, Price price,
                               Quantity quantity, StockThreshold threshold, ExpiryDate expiryDate) {
        super(itemCode, itemName, price, quantity, threshold);
        this.expiryDate = expiryDate;
    }

    public boolean isExpiringWithin(LocalDate today, int daysWindow) {
        if (this.getStatus() == ProductStatus.DISCONTINUED) return false;
        LocalDate windowEnd = today.plusDays(daysWindow);
        return this.expiryDate.isExpiringWithinWindow(today, windowEnd);
    }

    public ExpiryDate getExpiryDate() { return expiryDate; }
}
EOF


# ----------------------------------------------------------------
# WRITE MAVEN POM CONFIGURATIONS
# ----------------------------------------------------------------
echo "📄 Writing Maven Configurations..."

cat << 'EOF' > pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.digitalstockmanager</groupId>
    <artifactId>digital-stock-manager</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
        <relativePath/>
    </parent>

    <modules>
        <module>domain</module>
        <module>application</module>
        <module>infrastructure</module>
    </modules>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>${java.version}</maven.compiler.source>
        <maven.compiler.target>${java.version}</maven.compiler.target>
    </properties>
</project>
EOF

cat << 'EOF' > domain/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.digitalstockmanager</groupId>
        <artifactId>digital-stock-manager</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>domain</artifactId>
</project>
EOF

cat << 'EOF' > application/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.digitalstockmanager</groupId>
        <artifactId>digital-stock-manager</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>application</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.digitalstockmanager</groupId>
            <artifactId>domain</artifactId>
            <version>${project.version}</version>
        </dependency>
    </dependencies>
</project>
EOF

cat << 'EOF' > infrastructure/pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.digitalstockmanager</groupId>
        <artifactId>digital-stock-manager</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>infrastructure</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.digitalstockmanager</groupId>
            <artifactId>application</artifactId>
            <version>${project.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>
</project>
EOF

echo "✨ Domain layer updated with strict polymorphic rules!"
echo "👉 Action: Run this script and refresh Maven inside IntelliJ."