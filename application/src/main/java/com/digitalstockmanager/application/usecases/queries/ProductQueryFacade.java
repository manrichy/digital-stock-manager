package com.digitalstockmanager.application.usecases.queries;

import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import java.util.List;
import java.util.Optional;

public class ProductQueryFacade implements ProductQueryService {
    private final ProductQueryRepository queryRepository;

    public ProductQueryFacade(ProductQueryRepository queryRepository) {
        this.queryRepository = queryRepository;
    }

    @Override
    public Optional<ProductViewDto> getProductByCode(String itemCode) {
        return queryRepository.fetchByCode(itemCode);
    }

    @Override
    public List<ProductViewDto> searchInventory(String query) {
        return queryRepository.searchByKeywordOrSku(query);
    }

    @Override
    public List<ProductViewDto> getLowStockAlerts() {
        return queryRepository.fetchLowStockAlerts();
    }

    @Override
    public List<ProductViewDto> getExpiringProducts(int daysWindow) {
        return queryRepository.fetchExpiringProducts(daysWindow);
    }
}
