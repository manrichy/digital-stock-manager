package com.digitalstockmanager.application.ports.input.queries;

import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import java.util.List;
import java.util.Optional;

public interface ProductQueryService {
    Optional<ProductViewDto> getProductByCode(String itemCode);
    List<ProductViewDto> searchInventory(String query);
    List<ProductViewDto> getLowStockAlerts();
    List<ProductViewDto> getExpiringProducts(int daysWindow);
}
