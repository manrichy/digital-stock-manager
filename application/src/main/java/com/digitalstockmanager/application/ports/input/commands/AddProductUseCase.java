package com.digitalstockmanager.application.ports.input.commands;

import java.math.BigDecimal;
import java.time.LocalDate;

public interface AddProductUseCase {
    void execute(Command command);

    record Command(
        String itemCode,
        String itemName,
        BigDecimal price,
        int initialQuantity,
        int threshold,
        LocalDate expiryDate
    ) {}
}
