package com.smartwms.repository;

import com.smartwms.entity.OutboundOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface OutboundOrderRepository extends JpaRepository<OutboundOrder, Long> {
    List<OutboundOrder> findByTenantId(Long tenantId);
    List<OutboundOrder> findByTenantIdAndStatus(Long tenantId, String status);
    Optional<OutboundOrder> findByOrderNo(String orderNo);
}
