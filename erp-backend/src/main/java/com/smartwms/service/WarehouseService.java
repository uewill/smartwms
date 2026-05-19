package com.smartwms.service;

import com.smartwms.entity.Warehouse;
import com.smartwms.repository.WarehouseRepository;
import com.smartwms.repository.InventoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class WarehouseService {

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private InventoryRepository inventoryRepository;

    public List<Warehouse> getWarehouses(Long tenantId) {
        return warehouseRepository.findByTenantId(tenantId);
    }

    public Warehouse getWarehouse(Long id) {
        return warehouseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("仓库不存在"));
    }

    @Transactional
    public Warehouse createWarehouse(Long tenantId, Warehouse warehouse) {
        warehouse.setTenantId(tenantId);
        return warehouseRepository.save(warehouse);
    }

    @Transactional
    public Warehouse updateWarehouse(Long id, Warehouse warehouse) {
        Warehouse existing = warehouseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("仓库不存在"));

        existing.setName(warehouse.getName());
        existing.setAddress(warehouse.getAddress());
        existing.setContact(warehouse.getContact());
        existing.setPhone(warehouse.getPhone());
        existing.setStatus(warehouse.getStatus());

        return warehouseRepository.save(existing);
    }

    @Transactional
    public void deleteWarehouse(Long id) {
        warehouseRepository.deleteById(id);
    }

    public Map<String, Object> getWarehouseStats(Long tenantId) {
        List<Warehouse> warehouses = warehouseRepository.findByTenantId(tenantId);
        Map<String, Object> stats = new HashMap<>();

        for (Warehouse warehouse : warehouses) {
            Integer productCount = inventoryRepository.getProductCountByTenantId(tenantId);
            Integer totalStock = inventoryRepository.getTotalQuantityByTenantId(tenantId);
            warehouse.setProductCount(productCount != null ? productCount : 0);
            warehouse.setTotalStock(totalStock != null ? totalStock : 0);
        }

        stats.put("warehouses", warehouses);
        return stats;
    }
}
