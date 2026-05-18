package com.digitalstockmanager.application.ports.input.commands;

import java.math.BigDecimal;

public interface UpdateProductDetailsUseCase {
    void execute(Command command);

    record Command(
        String itemCode,
        String newName,
        BigDecimal newPrice,
        int newThreshold
    ) {}
}
