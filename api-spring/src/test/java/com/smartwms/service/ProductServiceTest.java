package com.smartwms.service;

import com.smartwms.entity.Product;
import com.smartwms.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductService productService;

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
        testProduct.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void testGetProducts_WithoutKeyword() {
        List<Product> products = Arrays.asList(testProduct);
        when(productRepository.findByTenantId(1L)).thenReturn(products);

        List<Product> result = productService.getProducts(1L, null, null);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("测试商品", result.get(0).getName());
        verify(productRepository).findByTenantId(1L);
    }

    @Test
    void testGetProducts_WithKeyword() {
        List<Product> products = Arrays.asList(testProduct);
        when(productRepository.searchByKeyword(1L, "测试")).thenReturn(products);

        List<Product> result = productService.getProducts(1L, "测试", null);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(productRepository).searchByKeyword(1L, "测试");
    }

    @Test
    void testGetProduct_Success() {
        when(productRepository.findById(1L)).thenReturn(Optional.of(testProduct));

        Product result = productService.getProduct(1L);

        assertNotNull(result);
        assertEquals("测试商品", result.getName());
        assertEquals("P001", result.getCode());
    }

    @Test
    void testGetProduct_NotFound() {
        when(productRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            productService.getProduct(999L);
        });
    }

    @Test
    void testCreateProduct_Success() {
        Product newProduct = new Product();
        newProduct.setCode("P002");
        newProduct.setName("新商品");
        newProduct.setSpec("规格B");
        newProduct.setUnit("件");
        newProduct.setPrice(BigDecimal.valueOf(199.99));

        when(productRepository.existsByCode("P002")).thenReturn(false);
        when(productRepository.save(any(Product.class))).thenAnswer(invocation -> {
            Product saved = invocation.getArgument(0);
            saved.setId(2L);
            return saved;
        });

        Product result = productService.createProduct(1L, newProduct);

        assertNotNull(result);
        assertEquals(2L, result.getId());
        assertEquals(1L, result.getTenantId());
        assertEquals(0, result.getStockQuantity());
        verify(productRepository).save(any(Product.class));
    }

    @Test
    void testCreateProduct_DuplicateCode() {
        Product newProduct = new Product();
        newProduct.setCode("P001");

        when(productRepository.existsByCode("P001")).thenReturn(true);

        assertThrows(RuntimeException.class, () -> {
            productService.createProduct(1L, newProduct);
        });

        verify(productRepository, never()).save(any(Product.class));
    }

    @Test
    void testUpdateProduct_Success() {
        Product updateData = new Product();
        updateData.setName("更新后的商品");
        updateData.setSpec("新规格");
        updateData.setUnit("箱");
        updateData.setPrice(BigDecimal.valueOf(299.99));
        updateData.setCostPrice(BigDecimal.valueOf(150.00));
        updateData.setWarningStock(20);
        updateData.setCategory("新类别");
        updateData.setRemark("备注信息");
        updateData.setImage("http://example.com/image.jpg");

        when(productRepository.findById(1L)).thenReturn(Optional.of(testProduct));
        when(productRepository.save(any(Product.class))).thenReturn(testProduct);

        Product result = productService.updateProduct(1L, updateData);

        assertNotNull(result);
        assertEquals("更新后的商品", testProduct.getName());
        assertEquals("新规格", testProduct.getSpec());
        assertEquals("箱", testProduct.getUnit());
        assertEquals(BigDecimal.valueOf(299.99), testProduct.getPrice());
        verify(productRepository).save(testProduct);
    }

    @Test
    void testUpdateProduct_NotFound() {
        Product updateData = new Product();
        updateData.setName("更新后的商品");

        when(productRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            productService.updateProduct(999L, updateData);
        });
    }

    @Test
    void testDeleteProduct_Success() {
        doNothing().when(productRepository).deleteById(1L);

        assertDoesNotThrow(() -> {
            productService.deleteProduct(1L);
        });

        verify(productRepository).deleteById(1L);
    }

    @Test
    void testGetLowStockProducts_Success() {
        Product lowStockProduct = new Product();
        lowStockProduct.setId(2L);
        lowStockProduct.setTenantId(1L);
        lowStockProduct.setName("低库存商品");
        lowStockProduct.setStockQuantity(5);
        lowStockProduct.setWarningStock(10);

        List<Product> lowStockProducts = Arrays.asList(lowStockProduct);
        when(productRepository.findLowStockByTenantId(1L)).thenReturn(lowStockProducts);

        List<Product> result = productService.getLowStockProducts(1L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("低库存商品", result.get(0).getName());
        verify(productRepository).findLowStockByTenantId(1L);
    }

    @Test
    void testGetProducts_WithCategory() {
        Product categoryProduct = new Product();
        categoryProduct.setId(3L);
        categoryProduct.setTenantId(1L);
        categoryProduct.setName("电子产品");
        categoryProduct.setCategory("电子产品");

        List<Product> products = Arrays.asList(categoryProduct);
        when(productRepository.findByTenantId(1L)).thenReturn(products);

        List<Product> result = productService.getProducts(1L, null, "电子产品");

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("电子产品", result.get(0).getCategory());
    }
}
