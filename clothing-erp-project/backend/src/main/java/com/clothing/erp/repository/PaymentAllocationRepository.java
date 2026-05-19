package com.clothing.erp.repository;

import com.clothing.erp.entity.PaymentAllocation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentAllocationRepository extends JpaRepository<PaymentAllocation, Long> {

    List<PaymentAllocation> findByPaymentId(Long paymentId);

    List<PaymentAllocation> findByOrderId(Long orderId);

    List<PaymentAllocation> findByOrderIdIn(List<Long> orderIds);
}
