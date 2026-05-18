package com.digitalstockmanager.application.ports.output;

import com.digitalstockmanager.domain.entities.StockItem;
import com.digitalstockmanager.domain.valueobjects.ItemCode;
import java.util.Optional;

public interface ProductCatalogRepository {
    void save(StockItem stockItem);
    Optional<StockItem> findByCode(ItemCode itemCode);
}
