package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.config.CurrentUser;
import com.clothing.erp.dto.purchase.*;
import com.clothing.erp.service.PurchaseOrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/shops/{shopId}/purchase-orders")
@RequiredArgsConstructor
public class PurchaseOrderController {

    private final PurchaseOrderService purchaseOrderService;

    @PostMapping
    public Result<PurchaseOrderVO> createPurchaseOrder(@PathVariable Long shopId,
                                                        @CurrentUser Long userId,
                                                        @Valid @RequestBody CreatePurchaseOrderRequest request) {
        PurchaseOrderVO vo = purchaseOrderService.createPurchaseOrder(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping
    public Result<Page<PurchaseOrderVO>> listPurchaseOrders(@PathVariable Long shopId,
                                                             PurchaseOrderQueryRequest query) {
        Page<PurchaseOrderVO> page = purchaseOrderService.listPurchaseOrders(shopId, query);
        return Result.success(page);
    }

    @GetMapping("/{orderId}")
    public Result<PurchaseOrderVO> getPurchaseOrder(@PathVariable Long shopId,
                                                     @PathVariable Long orderId) {
        PurchaseOrderVO vo = purchaseOrderService.getPurchaseOrder(shopId, orderId);
        return Result.success(vo);
    }

    @PostMapping("/return")
    public Result<PurchaseOrderVO> createReturnOrder(@PathVariable Long shopId,
                                                      @CurrentUser Long userId,
                                                      @Valid @RequestBody ReturnPurchaseRequest request) {
        PurchaseOrderVO vo = purchaseOrderService.createReturnOrder(shopId, userId, request);
        return Result.success(vo);
    }
}
