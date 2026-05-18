package com.digitalstockmanager.domain.exceptions;

public class InsufficientStockException extends DomainException {
    public InsufficientStockException(String itemCode, int current, int requested) {
        super(String.format("Insufficient stock for item [%s]. Available: %d, Requested: %d",
                itemCode, current, requested));
    }
}
