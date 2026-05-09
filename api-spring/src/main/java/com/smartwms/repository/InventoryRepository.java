package com.smartwms.repository;

import com.smartwms.entity.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {
    List<Inventory> findByTenantId(Long tenantId);
    List<Inventory> findByWarehouseId(Long warehouseId);
    Optional<Inventory> findByWarehouseIdAndProductId(Long warehouseId, Long productId);

    @Query("SELECT SUM(i.quantity) FROM Inventory i WHERE i.tenantId = ?1")
    Integer getTotalQuantityByTenantId(Long tenantId);

    @Query("SELECT COUNT(DISTINCT i.productId) FROM Inventory i WHERE i.tenantId = ?1")
    Integer getProductCountByTenantId(Long tenantId);
}
