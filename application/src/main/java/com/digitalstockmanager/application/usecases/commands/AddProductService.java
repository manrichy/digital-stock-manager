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
