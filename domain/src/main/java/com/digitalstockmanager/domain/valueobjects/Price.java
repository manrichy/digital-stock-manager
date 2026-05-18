package com.digitalstockmanager.domain.valueobjects;

import com.digitalstockmanager.domain.exceptions.DomainException;
import java.math.BigDecimal;

public final class Price {
    private final BigDecimal value;

    public Price(BigDecimal value) {
        if (value == null) {
            throw new DomainException("Price cannot be null.");
        }
        if (value.compareTo(BigDecimal.ZERO) < 0) {
            throw new DomainException("Price cannot be negative.");
        }
        this.value = value;
    }

    public BigDecimal getValue() { return value; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return value.compareTo(((Price) o).value) == 0;
    }

    @Override
    public int hashCode() { return value.hashCode(); }
}
