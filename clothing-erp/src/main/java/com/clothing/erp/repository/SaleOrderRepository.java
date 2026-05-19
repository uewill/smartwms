package com.clothing.erp.repository;

import com.clothing.erp.entity.SaleOrder;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface SaleOrderRepository extends JpaRepository<SaleOrder, Long> {

    Optional<SaleOrder> findByShopIdAndOrderNo(Long shopId, String orderNo);

    @Query("SELECT o FROM SaleOrder o WHERE o.shop.id = :shopId " +
           "AND (:paymentMethod IS NULL OR o.paymentMethod = :paymentMethod) " +
           "AND (:orderType IS NULL OR o.orderType = :orderType) " +
           "AND (:startDate IS NULL OR o.createdAt >= :startDate) " +
           "AND (:endDate IS NULL OR o.createdAt <= :endDate) " +
           "AND (:keyword IS NULL OR :keyword = '' OR o.orderNo LIKE %:keyword% OR o.customer.name LIKE %:keyword%) " +
           "ORDER BY o.createdAt DESC")
    Page<SaleOrder> findByShopIdWithFilter(@Param("shopId") Long shopId,
                                           @Param("keyword") String keyword,
                                           @Param("paymentMethod") SaleOrder.PaymentMethod paymentMethod,
                                           @Param("orderType") SaleOrder.SaleOrderType orderType,
                                           @Param("startDate") LocalDateTime startDate,
                                           @Param("endDate") LocalDateTime endDate,
                                           Pageable pageable);

    @Query("SELECT COALESCE(SUM(o.actualAmount), 0) FROM SaleOrder o WHERE o.shop.id = :shopId " +
           "AND o.orderType = 'SALE' AND o.status = 'COMPLETED' " +
           "AND o.createdAt >= :startTime AND o.createdAt <= :endTime")
    BigDecimal sumActualAmountByShopIdAndCreatedAtBetween(@Param("shopId") Long shopId,
                                                          @Param("startTime") LocalDateTime startTime,
                                                          @Param("endTime") LocalDateTime endTime);

    @Query("SELECT COUNT(o) FROM SaleOrder o WHERE o.shop.id = :shopId " +
           "AND o.orderType = 'SALE' AND o.status = 'COMPLETED' " +
           "AND o.createdAt >= :startTime AND o.createdAt <= :endTime")
    Long countByShopIdAndCreatedAtBetween(@Param("shopId") Long shopId,
                                          @Param("startTime") LocalDateTime startTime,
                                          @Param("endTime") LocalDateTime endTime);

    @Query("SELECT MAX(o.orderNo) FROM SaleOrder o WHERE o.shop.id = :shopId AND o.orderNo LIKE :prefix")
    String findMaxOrderNoByShopIdAndPrefix(@Param("shopId") Long shopId, @Param("prefix") String prefix);

    @Query("SELECT COALESCE(SUM(i.purchasePrice * i.quantity), 0) FROM SaleOrderItem i " +
           "WHERE i.order.shop.id = :shopId AND i.order.orderType = 'SALE' AND i.order.status = 'COMPLETED' " +
           "AND i.order.createdAt >= :startTime AND i.order.createdAt <= :endTime")
    BigDecimal sumPurchaseCostByShopIdAndCreatedAtBetween(@Param("shopId") Long shopId,
                                                          @Param("startTime") LocalDateTime startTime,
                                                          @Param("endTime") LocalDateTime endTime);

    @Query("SELECT o FROM SaleOrder o WHERE o.customer.id = :customerId " +
           "AND o.paymentMethod = 'CREDIT' AND o.orderType = :orderType AND o.status = 'COMPLETED' " +
           "ORDER BY o.createdAt ASC")
    List<SaleOrder> findByCustomerIdAndPaymentMethodCredit(@Param("customerId") Long customerId,
                                                           @Param("orderType") SaleOrderType orderType);

    @Query("SELECT o FROM SaleOrder o WHERE o.customer.id = :customerId " +
           "AND o.paymentMethod = 'CREDIT' AND o.orderType = 'SALE' AND o.status = 'COMPLETED' " +
           "AND o.createdAt >= :startTime AND o.createdAt <= :endTime " +
           "ORDER BY o.createdAt ASC")
    List<SaleOrder> findCreditOrdersByCustomerIdAndPeriod(@Param("customerId") Long customerId,
                                                          @Param("startTime") LocalDateTime startTime,
                                                          @Param("endTime") LocalDateTime endTime);

    @Query("SELECT COALESCE(SUM(o.actualAmount), 0) FROM SaleOrder o WHERE o.customer.id = :customerId " +
           "AND o.paymentMethod = 'CREDIT' AND o.orderType = 'SALE' AND o.status = 'COMPLETED' " +
           "AND o.createdAt < :beforeTime")
    BigDecimal sumCreditAmountBefore(@Param("customerId") Long customerId,
                                     @Param("beforeTime") LocalDateTime beforeTime);
}
