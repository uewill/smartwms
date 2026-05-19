package com.clothing.erp.repository;

import com.clothing.erp.entity.InventoryCheckItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InventoryCheckItemRepository extends JpaRepository<InventoryCheckItem, Long> {

    List<InventoryCheckItem> findByCheckId(Long checkId);
}
