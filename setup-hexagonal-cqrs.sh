#!/bin/bash

echo "🚀 Generating CORRECT Hexagonal Architecture with CQRS Structure..."

# 1. Clean up root directory single-module src artifact if it exists
rm -rf src

BASE_PATH="com/digitalstockmanager"

# ----------------------------------------------------------------
# 2. DOMAIN MODULE LAYER (Pure Business Logic Only)
# ----------------------------------------------------------------
echo "📁 Building Domain Module Packages..."
DOMAIN_DIR="domain/src/main/java/$BASE_PATH/domain"

mkdir -p "$DOMAIN_DIR/entities"
mkdir -p "$DOMAIN_DIR/valueobjects"
mkdir -p "$DOMAIN_DIR/exceptions"
mkdir -p "$DOMAIN_DIR/events"

# Keep Git/IntelliJ tracking active for empty folders
touch "$DOMAIN_DIR/entities/.gitkeep"
touch "$DOMAIN_DIR/valueobjects/.gitkeep"


# ----------------------------------------------------------------
# 3. APPLICATION MODULE LAYER (CQRS Use Cases & Ports Only)
# ----------------------------------------------------------------
echo "📁 Building Application Module Packages..."
APP_DIR="application/src/main/java/$BASE_PATH/application"

# Commands (Writes)
mkdir -p "$APP_DIR/usecases/commands"
mkdir -p "$APP_DIR/ports/input/commands"
mkdir -p "$APP_DIR/ports/output/commands"

# Queries (Reads)
mkdir -p "$APP_DIR/usecases/queries"
mkdir -p "$APP_DIR/ports/input/queries"
mkdir -p "$APP_DIR/ports/output/queries"

touch "$APP_DIR/usecases/commands/.gitkeep"
touch "$APP_DIR/usecases/queries/.gitkeep"


# ----------------------------------------------------------------
# 4. INFRASTRUCTURE MODULE LAYER (Primary/Secondary Adapters Only)
# ----------------------------------------------------------------
echo "📁 Building Infrastructure Module Packages..."
INFRA_DIR="infrastructure/src/main/java/$BASE_PATH/infrastructure"

# Primary Adapters (Driving - e.g., REST Controllers, Event Listeners)
mkdir -p "$INFRA_DIR/primary/web/commands"
mkdir -p "$INFRA_DIR/primary/web/queries"
mkdir -p "$INFRA_DIR/primary/eventlisteners"

# Secondary Adapters (Driven - e.g., Database Persistence, External API Clients)
mkdir -p "$INFRA_DIR/secondary/persistence/jpa"
mkdir -p "$INFRA_DIR/secondary/persistence/repositories"
mkdir -p "$INFRA_DIR/secondary/clients"

# Framework Config & Spring Boot Main Application Entry Point
mkdir -p "$INFRA_DIR/config"

touch "$INFRA_DIR/primary/web/commands/.gitkeep"
touch "$INFRA_DIR/secondary/persistence/repositories/.gitkeep"


# ----------------------------------------------------------------
# 5. RE-WRITE MAVEN POM CONFIGURATIONS (To establish parent/child links)
# ----------------------------------------------------------------

echo "📄 Writing Root Parent pom.xml..."
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

echo "📄 Writing Domain module pom.xml..."
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

echo "📄 Writing Application module pom.xml..."
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

echo "📄 Writing Infrastructure module pom.xml..."
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

echo "✨ Fixed Hexagonal + CQRS Structure generated perfectly!"
echo "👉 Now, safely refresh Maven inside IntelliJ."