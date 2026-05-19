package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.dto.product.*;
import com.clothing.erp.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shops/{shopId}")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping("/products")
    public Result<ProductVO> createProduct(@PathVariable Long shopId,
                                           @Valid @RequestBody CreateProductRequest request) {
        ProductVO product = productService.createProduct(shopId, request);
        return Result.success(product);
    }

    @PutMapping("/products/{productId}")
    public Result<ProductVO> updateProduct(@PathVariable Long shopId,
                                           @PathVariable Long productId,
                                           @Valid @RequestBody CreateProductRequest request) {
        ProductVO product = productService.updateProduct(shopId, productId, request);
        return Result.success(product);
    }

    @GetMapping("/products/{productId}")
    public Result<ProductVO> getProduct(@PathVariable Long shopId,
                                        @PathVariable Long productId) {
        ProductVO product = productService.getProduct(shopId, productId);
        return Result.success(product);
    }

    @GetMapping("/products")
    public Result<Page<ProductListVO>> listProducts(@PathVariable Long shopId,
                                                     ProductQueryRequest query) {
        Page<ProductListVO> page = productService.listProducts(shopId, query);
        return Result.success(page);
    }

    @DeleteMapping("/products/{productId}")
    public Result<Void> deleteProduct(@PathVariable Long shopId,
                                      @PathVariable Long productId) {
        productService.deleteProduct(shopId, productId);
        return Result.success();
    }

    @PutMapping("/products/{productId}/batch-price")
    public Result<Void> batchSetPrice(@PathVariable Long shopId,
                                      @PathVariable Long productId,
                                      @Valid @RequestBody BatchPriceRequest request) {
        productService.batchSetPrice(shopId, productId, request);
        return Result.success();
    }

    @GetMapping("/products/cache")
    public Result<List<CacheProductVO>> getCachedProducts(@PathVariable Long shopId) {
        List<CacheProductVO> products = productService.getCachedProducts(shopId);
        return Result.success(products);
    }

    @GetMapping("/skus/barcode/{barcode}")
    public Result<SkuVO> getSkuByBarcode(@PathVariable String barcode) {
        SkuVO sku = productService.getSkuByBarcode(barcode);
        return Result.success(sku);
    }
}
