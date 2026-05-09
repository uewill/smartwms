package com.smartwms.repository;

import com.smartwms.entity.Warehouse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface WarehouseRepository extends JpaRepository<Warehouse, Long> {
    List<Warehouse> findByTenantId(Long tenantId);
    List<Warehouse> findByTenantIdAndStatus(Long tenantId, String status);
}
