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
