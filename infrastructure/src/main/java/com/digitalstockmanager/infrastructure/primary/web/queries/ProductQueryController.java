package com.digitalstockmanager.infrastructure.primary.web.queries;

import com.digitalstockmanager.application.ports.input.queries.ProductQueryService;
import com.digitalstockmanager.application.usecases.queries.ProductViewDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductQueryController {

    private final ProductQueryService queryService;

    public ProductQueryController(ProductQueryService queryService) {
        this.queryService = queryService;
    }

    @GetMapping("/{code}")
    public ResponseEntity<ProductViewDto> getProductByCode(@PathVariable("code") String code) {
        return queryService.getProductByCode(code)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProductViewDto>> searchInventory(@RequestParam("q") String query) {
        return ResponseEntity.ok(queryService.searchInventory(query));
    }

    @GetMapping("/alerts/low-stock")
    public ResponseEntity<List<ProductViewDto>> getLowStockAlerts() {
        return ResponseEntity.ok(queryService.getLowStockAlerts());
    }

    @GetMapping("/alerts/expiring")
    public ResponseEntity<List<ProductViewDto>> getExpiringProducts(@RequestParam(value = "days", defaultValue = "7") int days) {
        return ResponseEntity.ok(queryService.getExpiringProducts(days));
    }
}
