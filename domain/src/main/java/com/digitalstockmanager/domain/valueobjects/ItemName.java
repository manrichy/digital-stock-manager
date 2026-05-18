package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;

public final class ItemName {
    private final String value;

    public ItemName(String value) {
        if (value == null || value.trim().isEmpty()) {
            throw new DomainException("Item name cannot be null or empty.");
        }
        if (value.trim().length() > 100) {
            throw new DomainException("Item name cannot exceed 100 characters.");
        }
        this.value = value.trim();
    }

    public String getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.equals(((ItemName) o).value);
    }

    @Override
    public int hashCode() { return value.hashCode(); }
}
