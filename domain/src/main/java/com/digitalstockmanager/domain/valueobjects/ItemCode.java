package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class ItemCode {
    private final String value;

    public ItemCode(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new DomainException("Item code cannot be null or empty.");
        }
        String cleaned = value.trim().toUpperCase();
        if (!cleaned.matches("^[A-Z0-9\\-]+$")) {
            throw new DomainException("Item code must be alphanumeric (hyphens allowed).");
        }
        this.value = cleaned;
    }

    public String getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.equals(((ItemCode) o).value);
    }

    @Override
    public int hashCode() { return value.hashCode(); }

    @Override
    public String toString() { return value; }
}
