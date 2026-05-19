package com.smartwms.repository;

import com.smartwms.entity.InboundOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface InboundOrderRepository extends JpaRepository<InboundOrder, Long> {
    List<InboundOrder> findByTenantId(Long tenantId);
    List<InboundOrder> findByTenantIdAndStatus(Long tenantId, String status);
    Optional<InboundOrder> findByOrderNo(String orderNo);
}
