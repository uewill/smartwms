package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.sale.*;
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
public class SaleOrderService {

    private final SaleOrderRepository saleOrderRepository;
    private final ProductSkuRepository productSkuRepository;
    private final CustomerRepository customerRepository;
    private final ShopRepository shopRepository;
    private final SysUserRepository sysUserRepository;
    private final StockMovementRepository stockMovementRepository;

    @Transactional
    public SaleOrderVO createSaleOrder(Long shopId, Long userId, CreateSaleOrderRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));
        SysUser user = sysUserRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        SaleOrder.PaymentMethod paymentMethod = SaleOrder.PaymentMethod.valueOf(request.getPaymentMethod());

        Customer customer = null;
        if (request.getCustomerId() != null) {
            customer = customerRepository.findByIdAndShopId(request.getCustomerId(), shopId)
                    .orElseThrow(() -> new BusinessException(ErrorCode.BAD_REQUEST, "客户不存在"));
        }

        if (paymentMethod == SaleOrder.PaymentMethod.CREDIT && customer == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "赊账支付必须关联客户");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "商品列表不能为空");
        }

        List<Long> skuIds = request.getItems().stream()
                .map(SaleItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (SaleItemDTO item : request.getItems()) {
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
        List<SaleOrderItem> orderItems = new ArrayList<>();

        for (SaleItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            BigDecimal unitPrice = itemDTO.getUnitPrice();
            BigDecimal effectivePrice = itemDTO.getDiscountPrice() != null
                    ? itemDTO.getDiscountPrice() : unitPrice;
            BigDecimal itemTotal = effectivePrice.multiply(BigDecimal.valueOf(itemDTO.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP);
            totalAmount = totalAmount.add(itemTotal);

            SaleOrderItem orderItem = new SaleOrderItem();
            orderItem.setSku(sku);
            orderItem.setProduct(sku.getProduct());
            orderItem.setColorName(sku.getColor() != null ? sku.getColor().getColorName() : null);
            orderItem.setSizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null);
            orderItem.setStyleNo(sku.getProduct().getStyleNo());
            orderItem.setQuantity(itemDTO.getQuantity());
            orderItem.setUnitPrice(unitPrice);
            orderItem.setTotalPrice(itemTotal);
            orderItem.setPurchasePrice(sku.getPurchasePrice() != null ? sku.getPurchasePrice() : BigDecimal.ZERO);
            orderItems.add(orderItem);
        }

        BigDecimal discountAmount = request.getDiscountAmount() != null
                ? request.getDiscountAmount() : BigDecimal.ZERO;
        BigDecimal actualAmount = totalAmount.subtract(discountAmount)
                .setScale(2, RoundingMode.HALF_UP);
        if (actualAmount.compareTo(BigDecimal.ZERO) < 0) {
            actualAmount = BigDecimal.ZERO;
        }

        String orderNo = generateOrderNo(shopId, "SO");

        SaleOrder order = new SaleOrder();
        order.setShop(shop);
        order.setOrderNo(orderNo);
        order.setCustomer(customer);
        order.setUser(user);
        order.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        order.setDiscountAmount(discountAmount.setScale(2, RoundingMode.HALF_UP));
        order.setActualAmount(actualAmount);
        order.setPaymentMethod(paymentMethod);
        order.setRemark(request.getRemark());
        order.setOrderType(SaleOrder.SaleOrderType.SALE);
        order.setStatus(SaleOrder.SaleOrderStatus.COMPLETED);
        order.setItems(orderItems);

        for (SaleOrderItem orderItem : orderItems) {
            orderItem.setOrder(order);
        }

        SaleOrder savedOrder = saleOrderRepository.save(order);

        for (SaleItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            sku.setStockQty(sku.getStockQty() - itemDTO.getQuantity());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shop);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.OUT);
            movement.setQuantity(itemDTO.getQuantity());
            movement.setRefType(StockMovement.RefType.SALE);
            movement.setRefId(savedOrder.getId());
            movement.setRemark("销售出库 " + savedOrder.getOrderNo());
            stockMovementRepository.save(movement);
        }

        if (paymentMethod == SaleOrder.PaymentMethod.CREDIT && customer != null) {
            customer.setTotalDebt(customer.getTotalDebt().add(actualAmount));
            customer.setLastPurchaseAt(LocalDateTime.now());
            customerRepository.save(customer);
        }

        return toSaleOrderVO(savedOrder);
    }

    @Transactional(readOnly = true)
    public SaleOrderVO getSaleOrder(Long shopId, Long orderId) {
        SaleOrder order = saleOrderRepository.findById(orderId)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "订单不存在"));
        if (!order.getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无操作权限");
        }
        return toSaleOrderVO(order);
    }

    @Transactional(readOnly = true)
    public Page<SaleOrderVO> listSaleOrders(Long shopId, SaleOrderQueryRequest query) {
        Pageable pageable = PageRequest.of(query.getPage(), query.getSize());

        SaleOrder.PaymentMethod paymentMethod = null;
        if (query.getPaymentMethod() != null && !query.getPaymentMethod().isEmpty()) {
            paymentMethod = SaleOrder.PaymentMethod.valueOf(query.getPaymentMethod());
        }

        SaleOrder.SaleOrderType orderType = null;
        if (query.getOrderType() != null && !query.getOrderType().isEmpty()) {
            orderType = SaleOrder.SaleOrderType.valueOf(query.getOrderType());
        }

        LocalDateTime startDate = null;
        LocalDateTime endDate = null;
        if (query.getStartDate() != null) {
            startDate = query.getStartDate().atStartOfDay();
        }
        if (query.getEndDate() != null) {
            endDate = query.getEndDate().atTime(LocalTime.MAX);
        }

        Page<SaleOrder> page = saleOrderRepository.findByShopIdWithFilter(
                shopId, query.getKeyword(), paymentMethod, orderType, startDate, endDate, pageable);

        return page.map(this::toSaleOrderVO);
    }

    @Transactional
    public SaleOrderVO createReturnOrder(Long shopId, Long userId, ReturnRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));
        SysUser user = sysUserRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        SaleOrder refOrder = saleOrderRepository.findById(request.getRefOrderId())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "原销售单不存在"));
        if (!refOrder.getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "无操作权限");
        }
        if (refOrder.getOrderType() != SaleOrder.SaleOrderType.SALE) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "只能对销售单发起退货");
        }

        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "退货商品列表不能为空");
        }

        List<Long> skuIds = request.getItems().stream()
                .map(ReturnItemDTO::getSkuId)
                .distinct()
                .toList();
        List<ProductSku> skus = productSkuRepository.findAllById(skuIds);
        Map<Long, ProductSku> skuMap = skus.stream()
                .collect(Collectors.toMap(ProductSku::getId, Function.identity()));

        for (ReturnItemDTO item : request.getItems()) {
            ProductSku sku = skuMap.get(item.getSkuId());
            if (sku == null) {
                throw new BusinessException(ErrorCode.SKU_NOT_FOUND, "SKU不存在: " + item.getSkuId());
            }
            if (!sku.getProduct().getShop().getId().equals(shopId)) {
                throw new BusinessException(ErrorCode.PERMISSION_DENIED, "SKU不属于当前店铺: " + item.getSkuId());
            }
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<SaleOrderItem> returnItems = new ArrayList<>();

        for (ReturnItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            BigDecimal itemTotal = itemDTO.getUnitPrice().multiply(BigDecimal.valueOf(itemDTO.getQuantity()))
                    .setScale(2, RoundingMode.HALF_UP);
            totalAmount = totalAmount.add(itemTotal);

            SaleOrderItem returnItem = new SaleOrderItem();
            returnItem.setSku(sku);
            returnItem.setProduct(sku.getProduct());
            returnItem.setColorName(sku.getColor() != null ? sku.getColor().getColorName() : null);
            returnItem.setSizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null);
            returnItem.setStyleNo(sku.getProduct().getStyleNo());
            returnItem.setQuantity(itemDTO.getQuantity());
            returnItem.setUnitPrice(itemDTO.getUnitPrice());
            returnItem.setTotalPrice(itemTotal);
            returnItem.setPurchasePrice(sku.getPurchasePrice() != null ? sku.getPurchasePrice() : BigDecimal.ZERO);
            returnItems.add(returnItem);
        }

        String orderNo = generateOrderNo(shopId, "SR");

        SaleOrder returnOrder = new SaleOrder();
        returnOrder.setShop(shop);
        returnOrder.setOrderNo(orderNo);
        returnOrder.setCustomer(refOrder.getCustomer());
        returnOrder.setUser(user);
        returnOrder.setTotalAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        returnOrder.setDiscountAmount(BigDecimal.ZERO);
        returnOrder.setActualAmount(totalAmount.setScale(2, RoundingMode.HALF_UP));
        returnOrder.setPaymentMethod(refOrder.getPaymentMethod());
        returnOrder.setOrderType(SaleOrder.SaleOrderType.RETURN);
        returnOrder.setRefOrderId(refOrder.getId());
        returnOrder.setStatus(SaleOrder.SaleOrderStatus.COMPLETED);
        returnOrder.setItems(returnItems);

        for (SaleOrderItem returnItem : returnItems) {
            returnItem.setOrder(returnOrder);
        }

        SaleOrder savedReturnOrder = saleOrderRepository.save(returnOrder);

        for (ReturnItemDTO itemDTO : request.getItems()) {
            ProductSku sku = skuMap.get(itemDTO.getSkuId());
            sku.setStockQty(sku.getStockQty() + itemDTO.getQuantity());
            productSkuRepository.save(sku);

            StockMovement movement = new StockMovement();
            movement.setShop(shop);
            movement.setSku(sku);
            movement.setMovementType(StockMovement.MovementType.IN);
            movement.setQuantity(itemDTO.getQuantity());
            movement.setRefType(StockMovement.RefType.SALE);
            movement.setRefId(savedReturnOrder.getId());
            movement.setRemark("退货入库 " + savedReturnOrder.getOrderNo());
            stockMovementRepository.save(movement);
        }

        if (refOrder.getPaymentMethod() == SaleOrder.PaymentMethod.CREDIT && refOrder.getCustomer() != null) {
            Customer customer = refOrder.getCustomer();
            BigDecimal newDebt = customer.getTotalDebt().subtract(totalAmount);
            customer.setTotalDebt(newDebt.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : newDebt);
            customerRepository.save(customer);
        }

        return toSaleOrderVO(savedReturnOrder);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getTodaySummary(Long shopId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        BigDecimal todaySales = saleOrderRepository.sumActualAmountByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);
        Long todayOrderCount = saleOrderRepository.countByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);
        BigDecimal todayCost = saleOrderRepository.sumPurchaseCostByShopIdAndCreatedAtBetween(
                shopId, startOfDay, endOfDay);

        BigDecimal todayProfit = todaySales.subtract(todayCost).setScale(2, RoundingMode.HALF_UP);

        return Map.of(
                "todaySales", todaySales,
                "todayProfit", todayProfit,
                "todayOrderCount", todayOrderCount
        );
    }

    private String generateOrderNo(Long shopId, String prefix) {
        String dateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String prefixWithDate = prefix + dateStr;
        String maxOrderNo = saleOrderRepository.findMaxOrderNoByShopIdAndPrefix(shopId, prefixWithDate + "%");

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

    private SaleOrderVO toSaleOrderVO(SaleOrder order) {
        List<SaleOrderItemVO> itemVOs = order.getItems() != null
                ? order.getItems().stream().map(this::toSaleOrderItemVO).toList()
                : List.of();

        return SaleOrderVO.builder()
                .id(order.getId())
                .orderNo(order.getOrderNo())
                .customerId(order.getCustomer() != null ? order.getCustomer().getId() : null)
                .customerName(order.getCustomer() != null ? order.getCustomer().getName() : null)
                .userName(order.getUser() != null ? order.getUser().getNickname() : null)
                .totalAmount(order.getTotalAmount())
                .discountAmount(order.getDiscountAmount())
                .actualAmount(order.getActualAmount())
                .paymentMethod(order.getPaymentMethod() != null ? order.getPaymentMethod().name() : null)
                .remark(order.getRemark())
                .orderType(order.getOrderType() != null ? order.getOrderType().name() : null)
                .refOrderId(order.getRefOrderId())
                .status(order.getStatus() != null ? order.getStatus().name() : null)
                .items(itemVOs)
                .createdAt(order.getCreatedAt())
                .build();
    }

    private SaleOrderItemVO toSaleOrderItemVO(SaleOrderItem item) {
        return SaleOrderItemVO.builder()
                .id(item.getId())
                .skuId(item.getSku() != null ? item.getSku().getId() : null)
                .styleNo(item.getStyleNo())
                .colorName(item.getColorName())
                .sizeName(item.getSizeName())
                .quantity(item.getQuantity())
                .unitPrice(item.getUnitPrice())
                .totalPrice(item.getTotalPrice())
                .purchasePrice(item.getPurchasePrice())
                .build();
    }
}
