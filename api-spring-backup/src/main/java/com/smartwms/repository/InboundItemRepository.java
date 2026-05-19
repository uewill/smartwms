package com.smartwms.repository;

import com.smartwms.entity.InboundItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InboundItemRepository extends JpaRepository<InboundItem, Long> {
    List<InboundItem> findByOrderId(Long orderId);
    void deleteByOrderId(Long orderId);
}
