package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class IndexController {

    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("SmartWMS API is running");
    }
}
