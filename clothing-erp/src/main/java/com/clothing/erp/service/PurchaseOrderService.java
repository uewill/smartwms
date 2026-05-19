package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.purchase.*;
import com.clothing.erp.entity.*;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PurchaseOrderService {

    private final PurchaseOrderRepository purchaseOrderRepository;
    private final ProductSkuRepository productSkuRepository;
    private final ShopRepository shopRepository;
    private final StockMovementRepository stockMovementRepository;

    @Transactional
    public PurchaseOrderVO createPurchaseOrder(Long shopId, Long userId, CreatePurchaseOrderRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "商品列表不能为空");
        }

        List<Long> skuIds = request.getItems().stream()
                .map(PurchaseItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (PurchaseItemDTO item : request.getItems()) {
            ProductSku sku = skuMap.get(item.getSkuId());
            if (sku == null) {
                throw new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在: " + item.getSkuId());
            }
            if (!sku.getProduct().getShop().getId().equals(shopId)) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺: " + item.getSkuId());
            }
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<PurchaseOrderItem> orderItems = new ArrayList<>();

        for (PurchaseItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            BigDecimal itemTotal = itemDTO.getUnitPrice().multiply(BigDecimal.valueOf(itemDTO.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP);
            totalAmount = totalAmount.add(itemTotal);

            PurchaseOrderItem orderItem = new PurchaseOrderItem();
            orderItem.setSku(sku);
            orderItem.setProduct(sku.getProduct());
            orderItem.setColorName(sku.getColor() != null ? sku.getColor().getColorName() : null);
            orderItem.setSizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null);
            orderItem.setStyleNo(sku.getProduct().getStyleNo());
            orderItem.setQuantity(itemDTO.getQuantity());
            orderItem.setUnitPrice(itemDTO.getUnitPrice());
            orderItem.setTotalPrice(itemTotal);
            orderItems.add(orderItem);
        }

        String orderNo = generateOrderNo(shopId, "PO");

        PurchaseOrder order = new PurchaseOrder();
        order.setShop(shop);
        order.setOrderNo(orderNo);
        order.setSupplierName(request.getSupplierName());
        order.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        order.setRemark(request.getRemark());
        order.setOrderType(PurchaseOrder.PurchaseOrderType.PURCHASE);
        order.setStatus(PurchaseOrder.PurchaseOrderStatus.COMPLETED);
        order.setItems(orderItems);

        for (PurchaseOrderItem orderItem : orderItems) {
            orderItem.setOrder(order);
        }

        PurchaseOrder savedOrder = purchaseOrderRepository.save(order);

        for (PurchaseItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            sku.setStockQty(sku.getStockQty() + itemDTO.getQuantity());
            sku.setPurchasePrice(itemDTO.getUnitPrice());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shop);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.IN);
            movement.setQuantity(itemDTO.getQuantity());
            movement.setRefType(StockMovement.RefType.PURCHASE);
            movement.setRefId(savedOrder.getId());
            movement.setRemark("采购入库 " + savedOrder.getOrderNo());
            stockMovementRepository.save(movement);
        }

        return toPurchaseOrderVO(savedOrder);
    }

    @Transactional(readOnly = true)
    public PurchaseOrderVO getPurchaseOrder(Long shopId, Long orderId) {
        PurchaseOrder order = purchaseOrderRepository.findById(orderId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "采购单不存在"));
        if (!order.getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无操作权限");
        }
        return toPurchaseOrderVO(order);
    }

    @Transactional(readOnly = true)
    public Page<PurchaseOrderVO> listPurchaseOrders(Long shopId, PurchaseOrderQueryRequest query) {
        Pageable pageable = PageRequest.of(query.getPage(), query.getSize());

        PurchaseOrder.PurchaseOrderType orderType = null;
        if (query.getOrderType() != null && !query.getOrderType().isEmpty()) {
            orderType = PurchaseOrder.PurchaseOrderType.valueOf(query.getOrderType());
        }

        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        if (query.getStartDate() != null) {
            startDate = query.getStartDate().atStartOfDay();
        }
        if (query.getEndDate() != null) {
            endDate = query.getEndDate().atTime(LocalTime.MAX);
        }

        Page<PurchaseOrder> page = purchaseOrderRepository.findByShopIdWithFilter(
                shopId, query.getKeyword(), orderType, startDate, endDate, pageable);

        return page.map(this::toPurchaseOrderVO);
    }

    @Transactional
    public PurchaseOrderVO createReturnOrder(Long shopId, Long userId, ReturnPurchaseRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        PurchaseOrder refOrder = purchaseOrderRepository.findById(request.getRefOrderId())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "原采购单不存在"));
        if (!refOrder.getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无操作权限");
        }
        if (refOrder.getOrderType() != PurchaseOrder.PurchaseOrderType.PURCHASE) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "只能对采购单发起退货");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "退货商品列表不能为空");
        }

        List<Long> skuIds = request.getItems().stream()
                .map(PurchaseItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (PurchaseItemDTO item : request.getItems()) {
            ProductSku sku = skuMap.get(item.getSkuId());
            if (sku == null) {
                throw new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在: " + item.getSkuId());
            }
            if (!sku.getProduct().getShop().getId().equals(shopId)) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺: " + item.getSkuId());
            }
            if (sku.getStockQty() < item.getQuantity()) {
                throw new BusinessException(ErrorCode.BAD_REQUEST,
                        "库存不足: " + sku.getProduct().getStyleNo() + " 库存" + sku.getStockQty());
            }
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<PurchaseOrderItem> returnItems = new ArrayList<>();

        for (PurchaseItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            BigDecimal itemTotal = itemDTO.getUnitPrice().multiply(BigDecimal.valueOf(itemDTO.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP);
            totalAmount = totalAmount.add(itemTotal);

            PurchaseOrderItem returnItem = new PurchaseOrderItem();
            returnItem.setSku(sku);
            returnItem.setProduct(sku.getProduct());
            returnItem.setColorName(sku.getColor() != null ? sku.getColor().getColorName() : null);
            returnItem.setSizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null);
            returnItem.setStyleNo(sku.getProduct().getStyleNo());
            returnItem.setQuantity(itemDTO.getQuantity());
            returnItem.setUnitPrice(itemDTO.getUnitPrice());
            returnItem.setTotalPrice(itemTotal);
            returnItems.add(returnItem);
        }

        String orderNo = generateOrderNo(shopId, "PR");

        PurchaseOrder returnOrder = new PurchaseOrder();
        returnOrder.setShop(shop);
        returnOrder.setOrderNo(orderNo);
        returnOrder.setSupplierName(refOrder.getSupplierName());
        returnOrder.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        returnOrder.setRemark(request.getRemark());
        returnOrder.setOrderType(PurchaseOrder.PurchaseOrderType.RETURN);
        returnOrder.setStatus(PurchaseOrder.PurchaseOrderStatus.COMPLETED);
        returnOrder.setItems(returnItems);

        for (PurchaseOrderItem returnItem : returnItems) {
            returnItem.setOrder(returnOrder);
        }

        PurchaseOrder savedReturnOrder = purchaseOrderRepository.save(returnOrder);

        for (PurchaseItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            sku.setStockQty(sku.getStockQty() - itemDTO.getQuantity());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shop);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.OUT);
            movement.setQuantity(itemDTO.getQuantity());
            movement.setRefType(StockMovement.RefType.PURCHASE);
            movement.setRefId(savedReturnOrder.getId());
            movement.setRemark("采购退货 " + savedReturnOrder.getOrderNo());
            stockMovementRepository.save(movement);
        }

        return toPurchaseOrderVO(savedReturnOrder);
    }

    private String generateOrderNo(Long shopId, String prefix) {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String prefixWithDate = prefix + dateStr;
        String maxOrderNo = purchaseOrderRepository.findMaxOrderNoByShopIdAndPrefix(shopId, prefixWithDate + "%");

        int seq = 1;
        if (maxOrderNo != null && maxOrderNo.length() > prefixWithDate.length()) {
            String seqStr = maxOrderNo.substring(prefixWithDate.length());
            try {
                seq = Integer.parseInt(seqStr) + 1;
            } catch (NumberFormatException e) {
                seq = 1;
            }
        }

        return prefixWithDate + String.format("%04d", seq);
    }

    private PurchaseOrderVO toPurchaseOrderVO(PurchaseOrder order) {
        List<PurchaseOrderItemVO> itemVOs = order.getItems() != null
                ? order.getItems().stream().map(this::toPurchaseOrderItemVO).toList()
                : List.of();

        return PurchaseOrderVO.builder()
                .id(order.getId())
                .orderNo(order.getOrderNo())
                .supplierName(order.getSupplierName())
                .totalAmount(order.getTotalAmount())
                .remark(order.getRemark())
                .orderType(order.getOrderType() != null ? order.getOrderType().name() : null)
                .status(order.getStatus() != null ? order.getStatus().name() : null)
                .items(itemVOs)
                .createdAt(order.getCreatedAt())
                .build();
    }

    private PurchaseOrderItemVO toPurchaseOrderItemVO(PurchaseOrderItem item) {
        return PurchaseOrderItemVO.builder()
                .id(item.getId())
                .skuId(item.getSku() != null ? item.getSku().getId() : null)
                .styleNo(item.getStyleNo())
                .colorName(item.getColorName())
                .sizeName(item.getSizeName())
                .quantity(item.getQuantity())
                .unitPrice(item.getUnitPrice())
                .totalPrice(item.getTotalPrice())
                .build();
    }
}
