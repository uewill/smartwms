package com.clothing.erp.repository;

import com.clothing.erp.entity.PaymentRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public interface PaymentRecordRepository extends JpaRepository<PaymentRecord, Long> {

    List<PaymentRecord> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    List<PaymentRecord> findByShopIdAndCreatedAtBetweenOrderByCreatedAtDesc(Long shopId,
                                                                            LocalDateTime startTime,
                                                                            LocalDateTime endTime);

    @Query("SELECT COALESCE(SUM(pr.amount), 0) FROM PaymentRecord pr WHERE pr.customer.id = :customerId " +
           "AND pr.createdAt < :beforeTime")
    BigDecimal sumPaymentAmountByCustomerIdBefore(@Param("customerId") Long customerId,
                                                   @Param("beforeTime") LocalDateTime beforeTime);

    @Query("SELECT pr FROM PaymentRecord pr WHERE pr.customer.id = :customerId " +
           "AND pr.createdAt >= :startTime AND pr.createdAt <= :endTime " +
           "ORDER BY pr.createdAt DESC")
    List<PaymentRecord> findByCustomerIdAndCreatedAtBetween(@Param("customerId") Long customerId,
                                                            @Param("startTime") LocalDateTime startTime,
                                                            @Param("endTime") LocalDateTime endTime);
}
