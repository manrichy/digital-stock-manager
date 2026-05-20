package com.digitalstockmanager.domain.entities;

import com.digitalstockmanager.domain.valueobjects.*;

public class StandardStockItem extends StockItem {

    public StandardStockItem(ItemCode itemCode, ItemName itemName, Price price,
                             Quantity quantity, StockThreshold threshold) {
        super(itemCode, itemName, price, quantity, threshold);
    }
}
