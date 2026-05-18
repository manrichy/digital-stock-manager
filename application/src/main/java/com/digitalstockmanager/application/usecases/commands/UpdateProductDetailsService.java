package com.digitalstockmanager.application.usecases.commands;

import com.digitalstockmanager.application.ports.input.commands.UpdateProductDetailsUseCase;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.exceptions.DomainException;
import com.digitalstockmanager.domain.valueobjects.*;

public class UpdateProductDetailsService implements UpdateProductDetailsUseCase {
    private final ProductCatalogRepository repository;

    public UpdateProductDetailsService(ProductCatalogRepository repository) {
        this.repository = repository;
    }

    @Override
    public void execute(Command cmd) {
        StockItem item = repository.findByCode(new ItemCode(cmd.itemCode()))
                .orElseThrow(() -> new DomainException("Product modification failed. Item not found: " + cmd.itemCode()));

        item.updateDetails(
            new ItemName(cmd.newName()),
            new Price(cmd.newPrice()),
            new StockThreshold(cmd.newThreshold())
        );

        repository.save(item);
    }
}
