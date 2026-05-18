package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.exceptions.InsufficientStockException;
import com.digitalstockmanager.domain.valueobjects.*;

import java.time.LocalDate;

public class StockItem {
    private final ItemCode itemCode;
    private ItemName itemName;
    private Price price;
    private Quantity quantity;
    private StockThreshold threshold;
    private ExpiryDate expiryDate;
    private ProductStatus status;

    private StockItem(ItemCode itemCode, ItemName itemName, Price price,
                      Quantity quantity, StockThreshold threshold, ExpiryDate expiryDate) {
        this.itemCode = itemCode;
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
        this.threshold = threshold;
        this.expiryDate = expiryDate;
        this.status = ProductStatus.ACTIVE;
    }

    public static StockItem onboard(ItemCode itemCode, ItemName itemName, Price price,
                                    Quantity initialQuantity, StockThreshold threshold, ExpiryDate expiryDate) {
        return new StockItem(itemCode, itemName, price, initialQuantity, threshold, expiryDate);
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

    public boolean isExpiringWithin(LocalDate today, int daysWindow) {
        if (this.status == ProductStatus.DISCONTINUED) return false;
        LocalDate windowEnd = today.plusDays(daysWindow);
        return this.expiryDate.isExpiringWithinWindow(today, windowEnd);
    }

    private void guardAgainstDiscontinued() {
        if (this.status == ProductStatus.DISCONTINUED) {
            throw new DomainException("Cannot modify stock data or quantities on a discontinued item.");
        }
    }

    public ItemCode getItemCode() { return itemCode; }
    public ItemName getItemName() { return itemName; }
    public Price getPrice() { return price; }
    public Quantity getQuantity() { return quantity; }
    public StockThreshold getThreshold() { return threshold; }
    public ExpiryDate getExpiryDate() { return expiryDate; }
    public ProductStatus getStatus() { return status; }
}
