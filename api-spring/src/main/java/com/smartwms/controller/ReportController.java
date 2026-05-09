package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.ReportService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @GetMapping("/dashboard")
    public ApiResponse<Map<String, Object>> getDashboard(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Map<String, Object> dashboard = reportService.getDashboard(tenantId);
        return ApiResponse.success(dashboard);
    }

    @GetMapping("/inventory")
    public ApiResponse<Map<String, Object>> getInventoryReport(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Map<String, Object> report = reportService.getInventoryReport(tenantId);
        return ApiResponse.success(report);
    }

    @GetMapping("/cost")
    public ApiResponse<Map<String, Object>> getCostReport(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Map<String, Object> report = reportService.getCostReport(tenantId);
        return ApiResponse.success(report);
    }
}
