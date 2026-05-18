package com.digitalstockmanager.application.ports.input.commands;

public interface RestockProductUseCase {
    void execute(String itemCode, int quantityAmount);
}
