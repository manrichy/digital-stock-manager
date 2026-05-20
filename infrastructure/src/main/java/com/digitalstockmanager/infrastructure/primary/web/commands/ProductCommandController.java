package com.digitalstockmanager.infrastructure.primary.web.commands;

import com.digitalstockmanager.application.ports.input.commands.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
public class ProductCommandController {

    private final AddProductUseCase addProductUseCase;
    private final UpdateProductDetailsUseCase updateProductDetailsUseCase;
    private final DiscontinueProductUseCase discontinueProductUseCase;
    private final RestockProductUseCase restockProductUseCase;
    private final DeductStockUseCase deductStockUseCase;

    public ProductCommandController(AddProductUseCase addProductUseCase,
                                    UpdateProductDetailsUseCase updateProductDetailsUseCase,
                                    DiscontinueProductUseCase discontinueProductUseCase,
                                    RestockProductUseCase restockProductUseCase,
                                    DeductStockUseCase deductStockUseCase) {
        this.addProductUseCase = addProductUseCase;
        this.updateProductDetailsUseCase = updateProductDetailsUseCase;
        this.discontinueProductUseCase = discontinueProductUseCase;
        this.restockProductUseCase = restockProductUseCase;
        this.deductStockUseCase = deductStockUseCase;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> onboardProduct(@RequestBody AddProductRequest request) {
        addProductUseCase.execute(new AddProductUseCase.Command(
            request.itemCode(), request.itemName(), request.price(),
            request.initialQuantity(), request.threshold(), request.expiryDate()
        ));
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "Product registered successfully"));
    }

    @PutMapping("/{code}")
    public ResponseEntity<Map<String, String>> updateDetails(@PathVariable("code") String code, @RequestBody UpdateDetailsRequest request) {
        updateProductDetailsUseCase.execute(new UpdateProductDetailsUseCase.Command(
            code, request.itemName(), request.price(), request.threshold()
        ));
        return ResponseEntity.ok(Map.of("message", "Product descriptions updated successfully"));
    }

    @PostMapping("/{code}/restock")
    public ResponseEntity<Map<String, String>> restock(@PathVariable("code") String code, @RequestBody Map<String, Integer> payload) {
        restockProductUseCase.execute(code, payload.get("amount"));
        return ResponseEntity.ok(Map.of("message", "Inventory batch added successfully"));
    }

    @PostMapping("/{code}/deduct")
    public ResponseEntity<Map<String, String>> deduct(@PathVariable("code") String code, @RequestBody Map<String, Integer> payload) {
        deductStockUseCase.execute(code, payload.get("amount"));
        return ResponseEntity.ok(Map.of("message", "Stock allocated successfully"));
    }

    @DeleteMapping("/{code}")
    public ResponseEntity<Map<String, String>> discontinue(@PathVariable("code") String code) {
        discontinueProductUseCase.execute(code);
        return ResponseEntity.ok(Map.of("message", "Product flagged as discontinued"));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleDomainErrors(RuntimeException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", ex.getMessage()));
    }

    public record AddProductRequest(String itemCode, String itemName, BigDecimal price, int initialQuantity, int threshold, LocalDate expiryDate) {}
    public record UpdateDetailsRequest(String itemName, BigDecimal price, int threshold) {}
}
