package com.digitalstockmanager.application.ports.output;

import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import java.util.List;
import java.util.Optional;

public interface ProductQueryRepository {
    Optional<ProductViewDto> fetchByCode(String itemCode);
    List<ProductViewDto> searchByKeywordOrSku(String query);
    List<ProductViewDto> fetchLowStockAlerts();
    List<ProductViewDto> fetchExpiringProducts(int daysWindow);
}
