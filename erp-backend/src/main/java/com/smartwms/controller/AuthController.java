package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.dto.AuthResult;
import com.smartwms.dto.LoginRequest;
import com.smartwms.dto.RegisterRequest;
import com.smartwms.entity.OperationLog;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/send-code")
    public ApiResponse<Void> sendCode(@RequestParam String phone, @RequestParam(defaultValue = "login") String type) {
        authService.sendCode(phone, type);
        return ApiResponse.success();
    }

    @PostMapping("/login-by-code")
    public ApiResponse<AuthResult> loginByCode(@RequestBody LoginRequest request) {
        AuthResult result = authService.loginByCode(request.getPhone(), request.getCode());
        return ApiResponse.success(result);
    }

    @PostMapping("/login-by-pwd")
    public ApiResponse<AuthResult> loginByPassword(@RequestBody LoginRequest request) {
        AuthResult result = authService.loginByPassword(request.getPhone(), request.getPassword());
        return ApiResponse.success(result);
    }

    @PostMapping("/register")
    public ApiResponse<AuthResult> register(@RequestBody RegisterRequest request) {
        AuthResult result = authService.register(request);
        return ApiResponse.success(result);
    }

    @PostMapping("/wx-login")
    public ApiResponse<AuthResult> wxLogin(@RequestBody Map<String, String> request) {
        AuthResult result = authService.wxLogin(request.get("wx_openid"));
        return ApiResponse.success(result);
    }

    @GetMapping("/user-info")
    public ApiResponse<AuthResult> getUserInfo(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute(AuthInterceptor.USER_ID);
        AuthResult result = authService.getUserInfo(userId);
        return ApiResponse.success(result);
    }

    @PostMapping("/bind-wechat")
    public ApiResponse<AuthResult> bindWechat(HttpServletRequest request, @RequestBody Map<String, String> body) {
        Long userId = (Long) request.getAttribute(AuthInterceptor.USER_ID);
        AuthResult result = authService.bindWechatByCode(userId, body.get("phone"), body.get("code"));
        return ApiResponse.success(result);
    }

    @PostMapping("/change-password")
    public ApiResponse<Void> changePassword(HttpServletRequest request, @RequestBody Map<String, String> body) {
        Long userId = (Long) request.getAttribute(AuthInterceptor.USER_ID);
        authService.changePassword(userId, body.get("oldPassword"), body.get("newPassword"));
        return ApiResponse.success();
    }

    @GetMapping("/operation-logs")
    public ApiResponse<List<OperationLog>> getOperationLogs(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<OperationLog> logs = authService.getOperationLogs(tenantId);
        return ApiResponse.success(logs);
    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout() {
        return ApiResponse.success();
    }
}
