package com.smartwms.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartwms.entity.Product;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.ProductService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ProductController.class)
class ProductControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ProductService productService;

    @Autowired
    private ObjectMapper objectMapper;

    private Product testProduct;

    @BeforeEach
    void setUp() {
        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setTenantId(1L);
        testProduct.setCode("P001");
        testProduct.setName("测试商品");
        testProduct.setSpec("规格A");
        testProduct.setUnit("个");
        testProduct.setPrice(BigDecimal.valueOf(99.99));
        testProduct.setCostPrice(BigDecimal.valueOf(50.00));
        testProduct.setWarningStock(10);
        testProduct.setStockQuantity(100);
        testProduct.setCategory("电子产品");
        testProduct.setStatus("active");
    }

    @Test
    void testGetProducts_Success() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getProducts(eq(1L), any(), any())).thenReturn(products);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/products")
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].name").value("测试商品"));
    }

    @Test
    void testGetProducts_WithKeyword() throws Exception {
        List<Product> products = Arrays.asList(testProduct);
        when(productService.getProducts(eq(1L), eq("测试"), any())).thenReturn(products);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/products")
                        .param("keyword", "测试")
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data[0].name").value("测试商品"));
    }

    @Test
    void testGetProduct_Success() throws Exception {
        when(productService.getProduct(1L)).thenReturn(testProduct);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.name").value("测试商品"))
                .andExpect(jsonPath("$.data.code").value("P001"));
    }

    @Test
    void testGetProduct_NotFound() throws Exception {
        when(productService.getProduct(999L)).thenThrow(new RuntimeException("商品不存在"));

        mockMvc.perform(MockMvcRequestBuilders.get("/api/products/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void testCreateProduct_Success() throws Exception {
        Product newProduct = new Product();
        newProduct.setCode("P002");
        newProduct.setName("新商品");
        newProduct.setSpec("规格B");
        newProduct.setUnit("件");
        newProduct.setPrice(BigDecimal.valueOf(199.99));

        when(productService.createProduct(eq(1L), any(Product.class))).thenReturn(testProduct);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newProduct))
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    void testUpdateProduct_Success() throws Exception {
        Product updateData = new Product();
        updateData.setName("更新后的商品");
        updateData.setSpec("新规格");

        when(productService.updateProduct(eq(1L), any(Product.class))).thenReturn(testProduct);

        mockMvc.perform(MockMvcRequestBuilders.put("/api/products/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateData)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }

    @Test
    void testDeleteProduct_Success() throws Exception {
        doNothing().when(productService).deleteProduct(1L);

        mockMvc.perform(MockMvcRequestBuilders.delete("/api/products/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        verify(productService).deleteProduct(1L);
    }

    @Test
    void testGetLowStockProducts_Success() throws Exception {
        Product lowStockProduct = new Product();
        lowStockProduct.setId(2L);
        lowStockProduct.setName("低库存商品");
        lowStockProduct.setStockQuantity(5);
        lowStockProduct.setWarningStock(10);

        when(productService.getLowStockProducts(1L)).thenReturn(Arrays.asList(lowStockProduct));

        mockMvc.perform(MockMvcRequestBuilders.get("/api/products/low-stock")
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isArray());
    }
}
