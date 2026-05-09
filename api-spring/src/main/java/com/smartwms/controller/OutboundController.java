package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.dto.OutboundOrderRequest;
import com.smartwms.entity.OutboundOrder;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.OutboundService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/outbound")
public class OutboundController {

    @Autowired
    private OutboundService outboundService;

    @GetMapping
    public ApiResponse<List<OutboundOrder>> getOrders(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<OutboundOrder> orders = outboundService.getOrders(tenantId);
        return ApiResponse.success(orders);
    }

    @GetMapping("/{id}")
    public ApiResponse<OutboundOrder> getOrder(@PathVariable Long id) {
        OutboundOrder order = outboundService.getOrder(id);
        return ApiResponse.success(order);
    }

    @PostMapping
    public ApiResponse<OutboundOrder> createOrder(HttpServletRequest request, @RequestBody OutboundOrderRequest orderRequest) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        OutboundOrder order = outboundService.createOrder(tenantId, orderRequest);
        return ApiResponse.success(order);
    }

    @PostMapping("/{id}/status")
    public ApiResponse<OutboundOrder> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        OutboundOrder order = outboundService.updateStatus(id, body.get("status"));
        return ApiResponse.success(order);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteOrder(@PathVariable Long id) {
        outboundService.deleteOrder(id);
        return ApiResponse.success();
    }
}
