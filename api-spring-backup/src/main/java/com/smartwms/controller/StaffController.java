package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.entity.Staff;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.StaffService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/staffs")
public class StaffController {

    @Autowired
    private StaffService staffService;

    @GetMapping
    public ApiResponse<List<Staff>> getStaffs(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<Staff> staffs = staffService.getStaffs(tenantId);
        return ApiResponse.success(staffs);
    }

    @GetMapping("/{id}")
    public ApiResponse<Staff> getStaff(@PathVariable Long id) {
        Staff staff = staffService.getStaff(id);
        return ApiResponse.success(staff);
    }

    @PostMapping
    public ApiResponse<Staff> createStaff(HttpServletRequest request, @RequestBody Staff staff) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Staff created = staffService.createStaff(tenantId, staff);
        return ApiResponse.success(created);
    }

    @PutMapping("/{id}")
    public ApiResponse<Staff> updateStaff(@PathVariable Long id, @RequestBody Staff staff) {
        Staff updated = staffService.updateStaff(id, staff);
        return ApiResponse.success(updated);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteStaff(@PathVariable Long id) {
        staffService.deleteStaff(id);
        return ApiResponse.success();
    }

    @PutMapping("/{id}/reset-pwd")
    public ApiResponse<Map<String, String>> resetPassword(@PathVariable Long id) {
        String newPassword = staffService.resetPassword(id);
        return ApiResponse.success(Map.of("password", newPassword));
    }
}
