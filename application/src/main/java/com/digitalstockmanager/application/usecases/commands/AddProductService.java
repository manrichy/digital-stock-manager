package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.AddProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.entities.StandardStockItem;
import com.digitalstockmanager.domain.entities.PerishableStockItem;
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

        ItemName name = new ItemName(cmd.itemName());
        Price price = new Price(cmd.price());
        Quantity initialQty = new Quantity(cmd.initialQuantity());
        StockThreshold threshold = new StockThreshold(cmd.threshold());

        StockItem item;
        // Business Rule: If an expiry date is provided, treat it as a PerishableStockItem. Otherwise, it is standard.
        if (cmd.expiryDate() != null) {
            item = new PerishableStockItem(code, name, price, initialQty, threshold, new ExpiryDate(cmd.expiryDate()));
        } else {
            item = new StandardStockItem(code, name, price, initialQty, threshold);
        }

        repository.save(item);
    }
}
