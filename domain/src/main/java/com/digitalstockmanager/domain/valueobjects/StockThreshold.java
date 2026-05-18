package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class StockThreshold {
    private final int value;

    public StockThreshold(int value) {
        if (value < 0) {
            throw new DomainException("Stock threshold cannot be negative.");
        }
        this.value = value;
    }

    public int getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value == ((StockThreshold) o).value;
    }

    @Override
    public int hashCode() { return value; }
}
