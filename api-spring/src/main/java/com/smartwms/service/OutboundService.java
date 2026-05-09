package com.smartwms.service;

import com.smartwms.dto.OutboundOrderRequest;
import com.smartwms.entity.*;
import com.smartwms.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class OutboundService {

    @Autowired
    private OutboundOrderRepository outboundOrderRepository;

    @Autowired
    private OutboundItemRepository outboundItemRepository;

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private ProductRepository productRepository;

    public List<OutboundOrder> getOrders(Long tenantId) {
        return outboundOrderRepository.findByTenantId(tenantId);
    }

    public OutboundOrder getOrder(Long id) {
        OutboundOrder order = outboundOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("出库单不存在"));
        order.setItems(outboundItemRepository.findByOrderId(id));
        return order;
    }

    @Transactional
    public OutboundOrder createOrder(Long tenantId, OutboundOrderRequest request) {
        OutboundOrder order = new OutboundOrder();
        order.setOrderNo("OUT" + System.currentTimeMillis());
        order.setTenantId(tenantId);
        order.setWarehouseId(request.getWarehouseId());
        order.setWarehouseName(request.getWarehouseName());
        order.setCustomer(request.getCustomer());
        order.setRemark(request.getRemark());
        order.setOperatorId(request.getOperatorId());
        order.setOperatorName(request.getOperatorName());
        order.setStatus("pending");

        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQuantity = 0;

        for (OutboundOrderRequest.OutboundItemRequest itemReq : request.getItems()) {
            totalQuantity += itemReq.getQuantity();
            totalAmount = totalAmount.add(itemReq.getCostPrice().multiply(BigDecimal.valueOf(itemReq.getQuantity())));
        }

        order.setTotalQuantity(totalQuantity);
        order.setTotalAmount(totalAmount);
        order = outboundOrderRepository.save(order);

        for (OutboundOrderRequest.OutboundItemRequest itemReq : request.getItems()) {
            OutboundItem item = new OutboundItem();
            item.setOrderId(order.getId());
            item.setProductId(itemReq.getProductId());
            item.setProductName(itemReq.getProductName());
            item.setProductCode(itemReq.getProductCode());
            item.setQuantity(itemReq.getQuantity());
            item.setCostPrice(itemReq.getCostPrice());
            outboundItemRepository.save(item);

            updateInventory(order.getWarehouseId(), itemReq.getProductId(), itemReq.getQuantity());
        }

        return getOrder(order.getId());
    }

    @Transactional
    public OutboundOrder updateStatus(Long id, String status) {
        OutboundOrder order = outboundOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("出库单不存在"));

        order.setStatus(status);
        return outboundOrderRepository.save(order);
    }

    @Transactional
    public void deleteOrder(Long id) {
        outboundItemRepository.deleteByOrderId(id);
        outboundOrderRepository.deleteById(id);
    }

    private void updateInventory(Long warehouseId, Long productId, int quantity) {
        Inventory inventory = inventoryRepository.findByWarehouseIdAndProductId(warehouseId, productId)
                .orElseThrow(() -> new RuntimeException("库存不足"));

        if (inventory.getQuantity() < quantity) {
            throw new RuntimeException("库存不足");
        }

        inventory.setQuantity(inventory.getQuantity() - quantity);

        Product product = productRepository.findById(productId).orElse(null);
        if (product != null) {
            product.setStockQuantity(Math.max(0, product.getStockQuantity() - quantity));
            productRepository.save(product);
        }

        inventoryRepository.save(inventory);
    }
}
