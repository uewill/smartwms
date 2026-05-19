package com.clothing.erp.repository;

import com.clothing.erp.entity.SaleOrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface SaleOrderItemRepository extends JpaRepository<SaleOrderItem, Long> {

    List<SaleOrderItem> findByOrderId(Long orderId);

    @Query("SELECT i.product.id AS productId, i.styleNo AS styleNo, i.product.name AS productName, " +
           "i.product.thumbUrl AS thumbUrl, " +
           "SUM(i.quantity) AS salesQuantity, SUM(i.totalPrice) AS salesAmount " +
           "FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId " +
           "AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "AND i.order.createdAt >= :startTime AND i.order.createdAt <= :endTime " +
           "GROUP BY i.product.id, i.styleNo, i.product.name, i.product.thumbUrl " +
           "ORDER BY salesQuantity DESC")
    List<Object[]> findHotProductsByShopIdAndPeriod(@Param("shopId") Long shopId,
                                                     @Param("startTime") LocalDateTime startTime,
                                                     @Param("endTime") LocalDateTime endTime);

    @Query("SELECT i.sku.id AS skuId, i.styleNo AS styleNo, i.product.name AS productName, " +
           "i.colorName AS colorName, i.sizeName AS sizeName, " +
           "MAX(i.order.createdAt) AS lastSaleDate " +
           "FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId " +
           "AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "GROUP BY i.sku.id, i.styleNo, i.product.name, i.colorName, i.sizeName")
    List<Object[]> findLastSaleDateByShopId(@Param("shopId") Long shopId);

    @Query("SELECT COALESCE(SUM(i.totalPrice), 0) FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "AND i.order.createdAt >= :startTime AND i.order.createdAt <= :endTime")
    java.math.BigDecimal sumRevenueByShopIdAndPeriod(@Param("shopId") Long shopId,
                                                      @Param("startTime") LocalDateTime startTime,
                                                      @Param("endTime") LocalDateTime endTime);

    @Query("SELECT COALESCE(SUM(i.purchasePrice * i.quantity), 0) FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "AND i.order.createdAt >= :startTime AND i.order.createdAt <= :endTime")
    java.math.BigDecimal sumCostByShopIdAndPeriod(@Param("shopId") Long shopId,
                                                   @Param("startTime") LocalDateTime startTime,
                                                   @Param("endTime") LocalDateTime endTime);

    @Query("SELECT CAST(i.order.createdAt AS date) AS date, " +
           "COALESCE(SUM(i.totalPrice), 0) AS revenue, " +
           "COALESCE(SUM(i.purchasePrice * i.quantity), 0) AS cost " +
           "FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "AND i.order.createdAt >= :startTime AND i.order.createdAt <= :endTime " +
           "GROUP BY CAST(i.order.createdAt AS date) " +
           "ORDER BY CAST(i.order.createdAt AS date) ASC")
    List<Object[]> findDailyProfitByShopIdAndPeriod(@Param("shopId") Long shopId,
                                                     @Param("startTime") LocalDateTime startTime,
                                                     @Param("endTime") LocalDateTime endTime);
}
