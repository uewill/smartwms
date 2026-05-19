package com.smartwms.service;

import com.smartwms.entity.*;
import com.smartwms.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ReportService {

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private InboundOrderRepository inboundOrderRepository;

    @Autowired
    private OutboundOrderRepository outboundOrderRepository;

    public Map<String, Object> getDashboard(Long tenantId) {
        Map<String, Object> dashboard = new HashMap<>();

        Integer totalProducts = productRepository.findByTenantId(tenantId).size();
        Integer totalQuantity = inventoryRepository.getTotalQuantityByTenantId(tenantId);
        Integer todayInbound = 0;
        Integer todayOutbound = 0;

        dashboard.put("totalProducts", totalProducts);
        dashboard.put("totalQuantity", totalQuantity != null ? totalQuantity : 0);
        dashboard.put("todayInbound", todayInbound);
        dashboard.put("todayOutbound", todayOutbound);
        dashboard.put("pendingInbound", inboundOrderRepository.findByTenantIdAndStatus(tenantId, "pending").size());
        dashboard.put("pendingOutbound", outboundOrderRepository.findByTenantIdAndStatus(tenantId, "pending").size());

        return dashboard;
    }

    public Map<String, Object> getInventoryReport(Long tenantId) {
        Map<String, Object> report = new HashMap<>();

        List<Product> allProducts = productRepository.findByTenantId(tenantId);
        Integer totalQuantity = inventoryRepository.getTotalQuantityByTenantId(tenantId);
        List<Product> lowStockProducts = productRepository.findLowStockByTenantId(tenantId);

        List<Warehouse> warehouses = warehouseRepository.findByTenantId(tenantId);
        List<Map<String, Object>> warehouseStats = new ArrayList<>();
        List<Map<String, Object>> productInventory = new ArrayList<>();

        for (Warehouse warehouse : warehouses) {
            Map<String, Object> stat = new HashMap<>();
            stat.put("warehouseId", warehouse.getId());
            stat.put("warehouseName", warehouse.getName());
            Integer quantity = inventoryRepository.getTotalQuantityByTenantId(tenantId);
            stat.put("quantity", quantity != null ? quantity : 0);
            warehouseStats.add(stat);
        }

        for (Product product : allProducts) {
            Map<String, Object> inv = new HashMap<>();
            inv.put("productId", product.getId());
            inv.put("productName", product.getName());
            inv.put("warehouseId", 0L);
            inv.put("warehouseName", "默认仓库");
            inv.put("quantity", product.getStockQuantity());
            productInventory.add(inv);
        }

        report.put("totalProductTypes", allProducts.size());
        report.put("totalQuantity", totalQuantity != null ? totalQuantity : 0);
        report.put("warehouseStats", warehouseStats);
        report.put("lowStockProducts", lowStockProducts);
        report.put("productInventory", productInventory);

        return report;
    }

    public Map<String, Object> getCostReport(Long tenantId) {
        Map<String, Object> report = new HashMap<>();

        List<InboundOrder> inboundOrders = inboundOrderRepository.findByTenantId(tenantId);
        List<OutboundOrder> outboundOrders = outboundOrderRepository.findByTenantId(tenantId);

        BigDecimal monthInboundCost = BigDecimal.ZERO;
        BigDecimal monthOutboundCost = BigDecimal.ZERO;
        BigDecimal totalInventoryValue = BigDecimal.ZERO;

        for (InboundOrder order : inboundOrders) {
            monthInboundCost = monthInboundCost.add(order.getTotalAmount());
        }

        for (OutboundOrder order : outboundOrders) {
            monthOutboundCost = monthOutboundCost.add(order.getTotalAmount());
        }

        List<Product> products = productRepository.findByTenantId(tenantId);
        for (Product product : products) {
            totalInventoryValue = totalInventoryValue.add(product.getCostPrice().multiply(BigDecimal.valueOf(product.getStockQuantity())));
        }

        BigDecimal averageCost = products.isEmpty() ? BigDecimal.ZERO :
                totalInventoryValue.divide(BigDecimal.valueOf(products.size()), 2, BigDecimal.ROUND_HALF_UP);

        List<Map<String, Object>> monthlyTrend = new ArrayList<>();
        Map<String, Object> trend = new HashMap<>();
        trend.put("month", "2024-01");
        trend.put("inboundCost", monthInboundCost);
        trend.put("outboundCost", monthOutboundCost);
        monthlyTrend.add(trend);

        report.put("monthInboundCost", monthInboundCost);
        report.put("monthOutboundCost", monthOutboundCost);
        report.put("totalInventoryValue", totalInventoryValue);
        report.put("averageCost", averageCost);
        report.put("monthlyTrend", monthlyTrend);

        return report;
    }
}
