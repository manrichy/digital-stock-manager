package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.DiscontinueProductUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.ItemCode;

public class DiscontinueProductService implements DiscontinueProductUseCase {
    private final ProductCatalogRepository repository;

    public DiscontinueProductService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(String itemCode) {
        StockItem item = repository.findByCode(new ItemCode(itemCode))
                .orElseThrow(() -> new DomainException("Retirement failed. StockItem target not found: " + itemCode));

        item.discontinue();
        repository.save(item);
    }
}
