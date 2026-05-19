package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.entity.Warehouse;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.WarehouseService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/warehouses")
public class WarehouseController {

    @Autowired
    private WarehouseService warehouseService;

    @GetMapping
    public ApiResponse<List<Warehouse>> getWarehouses(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<Warehouse> warehouses = warehouseService.getWarehouses(tenantId);
        return ApiResponse.success(warehouses);
    }

    @GetMapping("/{id}")
    public ApiResponse<Warehouse> getWarehouse(@PathVariable Long id) {
        Warehouse warehouse = warehouseService.getWarehouse(id);
        return ApiResponse.success(warehouse);
    }

    @PostMapping
    public ApiResponse<Warehouse> createWarehouse(HttpServletRequest request, @RequestBody Warehouse warehouse) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Warehouse created = warehouseService.createWarehouse(tenantId, warehouse);
        return ApiResponse.success(created);
    }

    @PutMapping("/{id}")
    public ApiResponse<Warehouse> updateWarehouse(@PathVariable Long id, @RequestBody Warehouse warehouse) {
        Warehouse updated = warehouseService.updateWarehouse(id, warehouse);
        return ApiResponse.success(updated);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteWarehouse(@PathVariable Long id) {
        warehouseService.deleteWarehouse(id);
        return ApiResponse.success();
    }

    @GetMapping("/stats")
    public ApiResponse<Map<String, Object>> getWarehouseStats(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Map<String, Object> stats = warehouseService.getWarehouseStats(tenantId);
        return ApiResponse.success(stats);
    }
}
