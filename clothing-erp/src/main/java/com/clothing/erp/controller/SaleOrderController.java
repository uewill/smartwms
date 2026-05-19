package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.config.CurrentUser;
import com.clothing.erp.dto.sale.*;
import com.clothing.erp.service.SaleOrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/shops/{shopId}/sale-orders")
@RequiredArgsConstructor
public class SaleOrderController {

    private final SaleOrderService saleOrderService;

    @PostMapping
    public Result<SaleOrderVO> createSaleOrder(@PathVariable Long shopId,
                                                @CurrentUser Long userId,
                                                @Valid @RequestBody CreateSaleOrderRequest request) {
        SaleOrderVO vo = saleOrderService.createSaleOrder(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping
    public Result<Page<SaleOrderVO>> listSaleOrders(@PathVariable Long shopId,
                                                     SaleOrderQueryRequest query) {
        Page<SaleOrderVO> page = saleOrderService.listSaleOrders(shopId, query);
        return Result.success(page);
    }

    @GetMapping("/{orderId}")
    public Result<SaleOrderVO> getSaleOrder(@PathVariable Long shopId,
                                             @PathVariable Long orderId) {
        SaleOrderVO vo = saleOrderService.getSaleOrder(shopId, orderId);
        return Result.success(vo);
    }

    @PostMapping("/return")
    public Result<SaleOrderVO> createReturnOrder(@PathVariable Long shopId,
                                                  @CurrentUser Long userId,
                                                  @Valid @RequestBody ReturnRequest request) {
        SaleOrderVO vo = saleOrderService.createReturnOrder(shopId, userId, request);
        return Result.success(vo);
    }

    @GetMapping("/today-summary")
    public Result<Map<String, Object>> getTodaySummary(@PathVariable Long shopId) {
        Map<String, Object> summary = saleOrderService.getTodaySummary(shopId);
        return Result.success(summary);
    }
}
