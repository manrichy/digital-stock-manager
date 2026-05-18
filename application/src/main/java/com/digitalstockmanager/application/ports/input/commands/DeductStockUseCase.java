package com.digitalstockmanager.application.ports.input.commands;

public interface DeductStockUseCase {
    void execute(String itemCode, int quantityAmount);
}
