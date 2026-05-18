package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class Quantity {
    private final int value;

    public Quantity(int value) {
        if (value < 0) {
            throw new DomainException("Quantity cannot be negative.");
        }
        this.value = value;
    }

    public int getValue() { return value; }

    public Quantity add(Quantity other) {
        return new Quantity(this.value + other.value);
    }

    public Quantity subtract(Quantity other) {
        return new Quantity(this.value - other.value);
    }

    public boolean isGreaterThanOrEqualTo(Quantity other) {
        return this.value >= other.value;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value == ((Quantity) o).value;
    }

    @Override
    public int hashCode() { return value; }
}
