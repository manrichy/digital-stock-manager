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
