package com.smartwms.service;

import com.smartwms.dto.InboundOrderRequest;
import com.smartwms.entity.*;
import com.smartwms.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class InboundService {

    @Autowired
    private InboundOrderRepository inboundOrderRepository;

    @Autowired
    private InboundItemRepository inboundItemRepository;

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private ProductRepository productRepository;

    public List<InboundOrder> getOrders(Long tenantId) {
        return inboundOrderRepository.findByTenantId(tenantId);
    }

    public InboundOrder getOrder(Long id) {
        InboundOrder order = inboundOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("入库单不存在"));
        order.setItems(inboundItemRepository.findByOrderId(id));
        return order;
    }

    @Transactional
    public InboundOrder createOrder(Long tenantId, InboundOrderRequest request) {
        InboundOrder order = new InboundOrder();
        order.setOrderNo("IN" + System.currentTimeMillis());
        order.setTenantId(tenantId);
        order.setWarehouseId(request.getWarehouseId());
        order.setWarehouseName(request.getWarehouseName());
        order.setSupplier(request.getSupplier());
        order.setRemark(request.getRemark());
        order.setOperatorId(request.getOperatorId());
        order.setOperatorName(request.getOperatorName());
        order.setStatus("pending");

        BigDecimal totalAmount = BigDecimal.ZERO;
        int totalQuantity = 0;

        for (InboundOrderRequest.InboundItemRequest itemReq : request.getItems()) {
            totalQuantity += itemReq.getQuantity();
            totalAmount = totalAmount.add(itemReq.getPrice().multiply(BigDecimal.valueOf(itemReq.getQuantity())));
        }

        order.setTotalQuantity(totalQuantity);
        order.setTotalAmount(totalAmount);
        order = inboundOrderRepository.save(order);

        for (InboundOrderRequest.InboundItemRequest itemReq : request.getItems()) {
            InboundItem item = new InboundItem();
            item.setOrderId(order.getId());
            item.setProductId(itemReq.getProductId());
            item.setProductName(itemReq.getProductName());
            item.setProductCode(itemReq.getProductCode());
            item.setQuantity(itemReq.getQuantity());
            item.setPrice(itemReq.getPrice());
            item.setAmount(itemReq.getPrice().multiply(BigDecimal.valueOf(itemReq.getQuantity())));
            inboundItemRepository.save(item);

            updateInventory(order.getWarehouseId(), itemReq.getProductId(), itemReq.getProductName(), itemReq.getQuantity());
        }

        return getOrder(order.getId());
    }

    @Transactional
    public InboundOrder updateStatus(Long id, String status) {
        InboundOrder order = inboundOrderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("入库单不存在"));

        order.setStatus(status);
        return inboundOrderRepository.save(order);
    }

    @Transactional
    public void deleteOrder(Long id) {
        inboundItemRepository.deleteByOrderId(id);
        inboundOrderRepository.deleteById(id);
    }

    private void updateInventory(Long warehouseId, Long productId, String productName, int quantity) {
        Inventory inventory = inventoryRepository.findByWarehouseIdAndProductId(warehouseId, productId)
                .orElseGet(() -> {
                    Inventory newInv = new Inventory();
                    newInv.setWarehouseId(warehouseId);
                    newInv.setProductId(productId);
                    newInv.setProductName(productName);
                    newInv.setQuantity(0);
                    return newInv;
                });

        inventory.setQuantity(inventory.getQuantity() + quantity);

        Product product = productRepository.findById(productId).orElse(null);
        if (product != null) {
            product.setStockQuantity(product.getStockQuantity() + quantity);
            productRepository.save(product);
        }

        inventoryRepository.save(inventory);
    }
}
