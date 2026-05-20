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
