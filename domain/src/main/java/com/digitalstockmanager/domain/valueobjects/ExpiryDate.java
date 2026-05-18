package com.digitalstockmanager.domain.valueobjects;

import java.time.LocalDate;
import java.util.Optional;

public final class ExpiryDate {
    private final LocalDate value;

    public ExpiryDate(LocalDate value) {
        this.value = value;
    }

    public Optional<LocalDate> getValue() {
        return Optional.ofNullable(value);
    }

    public boolean isExpiredAsOf(LocalDate date) {
        return value != null && value.isBefore(date);
    }

    public boolean isExpiringWithinWindow(LocalDate start, LocalDate end) {
        if (value == null) return false;
        return !value.isBefore(start) && !value.isAfter(end);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ExpiryDate that = (ExpiryDate) o;
        return (value == null && that.value == null) || (value != null && value.equals(that.value));
    }

    @Override
    public int hashCode() {
        return value != null ? value.hashCode() : 0;
    }
}
