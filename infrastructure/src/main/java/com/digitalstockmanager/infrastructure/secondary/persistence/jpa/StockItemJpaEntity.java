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
    private String productType; // Explicit type tracking: "STANDARD" or "PERISHABLE"

    // Default constructor for JPA
    public StockItemJpaEntity() {}

    public StockItemJpaEntity(String itemCode, String itemName, BigDecimal price,
                              int quantity, int threshold, LocalDate expiryDate, String status, String productType) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.expiryDate = expiryDate;
        this.status = status;
        this.productType = productType;
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
    public String getProductType() { return productType; }
    public void setProductType(String productType) { this.productType = productType; }
}
