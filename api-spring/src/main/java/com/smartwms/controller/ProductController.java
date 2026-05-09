package com.smartwms.controller;

import com.smartwms.dto.ApiResponse;
import com.smartwms.entity.Product;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    public ApiResponse<List<Product>> getProducts(
            HttpServletRequest request,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<Product> products = productService.getProducts(tenantId, keyword, category);
        return ApiResponse.success(products);
    }

    @GetMapping("/{id}")
    public ApiResponse<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getProduct(id);
        return ApiResponse.success(product);
    }

    @PostMapping
    public ApiResponse<Product> createProduct(HttpServletRequest request, @RequestBody Product product) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        Product created = productService.createProduct(tenantId, product);
        return ApiResponse.success(created);
    }

    @PutMapping("/{id}")
    public ApiResponse<Product> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        Product updated = productService.updateProduct(id, product);
        return ApiResponse.success(updated);
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ApiResponse.success();
    }

    @GetMapping("/low-stock")
    public ApiResponse<List<Product>> getLowStockProducts(HttpServletRequest request) {
        Long tenantId = (Long) request.getAttribute(AuthInterceptor.TENANT_ID);
        List<Product> products = productService.getLowStockProducts(tenantId);
        return ApiResponse.success(products);
    }
}
