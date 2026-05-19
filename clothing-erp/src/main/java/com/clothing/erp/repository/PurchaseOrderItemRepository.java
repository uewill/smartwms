package com.clothing.erp.repository;

import com.clothing.erp.entity.PurchaseOrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PurchaseOrderItemRepository extends JpaRepository<PurchaseOrderItem, Long> {

    List<PurchaseOrderItem> findByOrderId(Long orderId);
}
