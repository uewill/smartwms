package com.smartwms.repository;

import com.smartwms.entity.OutboundItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OutboundItemRepository extends JpaRepository<OutboundItem, Long> {
    List<OutboundItem> findByOrderId(Long orderId);
    void deleteByOrderId(Long orderId);
}
