package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.DeductStockUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.ItemCode;
import com.digitalstockmanager.domain.valueobjects.Quantity;

public class DeductStockService implements DeductStockUseCase {
    private final ProductCatalogRepository repository;

    public DeductStockService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(String itemCode, int quantityAmount) {
        StockItem item = repository.findByCode(new ItemCode(itemCode))
                .orElseThrow(() -> new DomainException("Fulfillment subtraction failed. Item missing: " + itemCode));

        item.deduct(new Quantity(quantityAmount));
        repository.save(item);
    }
}
