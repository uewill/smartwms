package com.clothing.erp.repository;

import com.clothing.erp.entity.PurchaseOrder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Long> {

    Optional<PurchaseOrder> findByShopIdAndOrderNo(Long shopId, String orderNo);

    @Query("SELECT o FROM PurchaseOrder o WHERE o.shop.id = :shopId " +
           "AND (:orderType IS NULL OR o.orderType = :orderType) " +
           "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
           "AND (:endDate IS NULL OR o.createdAt <= :endDate) " +
           "AND (:keyword IS NULL OR :keyword = '' OR o.orderNo LIKE %:keyword% OR o.supplierName LIKE %:keyword%) " +
           "ORDER BY o.createdAt DESC")
    Page<PurchaseOrder> findByShopIdWithFilter(@Param("shopId") Long shopId,
                                                @Param("keyword") String keyword,
                                                @Param("orderType") PurchaseOrder.PurchaseOrderType orderType,
                                                @Param("startDate") LocalDateTime startDate,
                                                @Param("endDate") LocalDateTime endDate,
                                                Pageable pageable);

    @Query("SELECT MAX(o.orderNo) FROM PurchaseOrder o WHERE o.shop.id = :shopId AND o.orderNo LIKE :prefix")
    String findMaxOrderNoByShopIdAndPrefix(@Param("shopId") Long shopId, @Param("prefix") String prefix);
}
