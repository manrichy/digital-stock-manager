package com.digitalstockmanager.infrastructure.secondary.persistence.jpa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.util.List;

public interface SpringDataProductRepository extends JpaRepository<StockItemJpaEntity, String> {

    @Query("SELECT s FROM StockItemJpaEntity s WHERE UPPER(s.itemName) LIKE UPPER(CONCAT('%', :query, '%')) OR UPPER(s.itemCode) LIKE UPPER(CONCAT('%', :query, '%'))")
    List<StockItemJpaEntity> searchByKeywordOrSku(@Param("query") String query);

    @Query("SELECT s FROM StockItemJpaEntity s WHERE s.status = 'ACTIVE' AND s.quantity <= s.threshold")
    List<StockItemJpaEntity> findLowStockAlerts();

    @Query("SELECT s FROM StockItemJpaEntity s WHERE s.status = 'ACTIVE' AND s.productType = 'PERISHABLE' AND s.expiryDate IS NOT NULL AND s.expiryDate BETWEEN :today AND :windowEnd")
    List<StockItemJpaEntity> findExpiringProducts(@Param("today") LocalDate today, @Param("windowEnd") LocalDate windowEnd);
}
