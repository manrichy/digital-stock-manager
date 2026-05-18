package com.digitalstockmanager.infrastructure.config;

import com.digitalstockmanager.application.ports.input.commands.*;
import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.ports.output.ProductCatalogRepository;
import com.digitalstockmanager.application.ports.output.ProductQueryRepository;
import com.digitalstockmanager.application.usecases.commands.*;
import com.digitalstockmanager.application.usecases.queries.ProductQueryFacade;
import com.digitalstockmanager.infrastructure.secondary.persistence.repositories.ProductRepositoryAdapter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DomainUseCaseConfiguration {

    @Bean
    public AddProductUseCase addProductUseCase(ProductRepositoryAdapter adapter) {
        return new AddProductService(adapter);
    }

    @Bean
    public UpdateProductDetailsUseCase updateProductDetailsUseCase(ProductRepositoryAdapter adapter) {
        return new UpdateProductDetailsService(adapter);
    }

    @Bean
    public DiscontinueProductUseCase discontinueProductUseCase(ProductRepositoryAdapter adapter) {
        return new DiscontinueProductService(adapter);
    }

    @Bean
    public RestockProductUseCase restockProductUseCase(ProductRepositoryAdapter adapter) {
        return new RestockProductService(adapter);
    }

    @Bean
    public DeductStockUseCase deductStockUseCase(ProductRepositoryAdapter adapter) {
        return new DeductStockService(adapter);
    }

    @Bean
    public ProductQueryService productQueryService(ProductRepositoryAdapter adapter) {
        return new ProductQueryFacade(adapter);
    }
}
