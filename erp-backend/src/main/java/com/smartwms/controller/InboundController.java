package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.dto.InboundOrderRequest;
import com.smartwms.entity.InboundOrder;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.InboundService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/inbound")
public class InboundController {

    @Autowired
    private InboundService inboundService;

    @GetMapping
    public ApiResponse<List<InboundOrder>> getOrders(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<InboundOrder> orders = inboundService.getOrders(tenantId);
        return ApiResponse.success(orders);
    }

    @GetMapping("/{id}")
    public ApiResponse<InboundOrder> getOrder(@PathVariable Long id) {
        InboundOrder order = inboundService.getOrder(id);
        return ApiResponse.success(order);
    }

    @PostMapping
    public ApiResponse<InboundOrder> createOrder(HttpServletRequest request, @RequestBody InboundOrderRequest orderRequest) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        InboundOrder order = inboundService.createOrder(tenantId, orderRequest);
        return ApiResponse.success(order);
    }

    @PostMapping("/{id}/status")
    public ApiResponse<InboundOrder> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        InboundOrder order = inboundService.updateStatus(id, body.get("status"));
        return ApiResponse.success(order);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteOrder(@PathVariable Long id) {
        inboundService.deleteOrder(id);
        return ApiResponse.success();
    }
}
