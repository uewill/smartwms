package com.smartwms.service;

import com.smartwms.entity.Warehouse;
import com.smartwms.repository.InventoryRepository;
import com.smartwms.repository.WarehouseRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WarehouseServiceTest {

    @Mock
    private WarehouseRepository warehouseRepository;

    @Mock
    private InventoryRepository inventoryRepository;

    @InjectMocks
    private WarehouseService warehouseService;

    private Warehouse testWarehouse;

    @BeforeEach
    void setUp() {
        testWarehouse = new Warehouse();
        testWarehouse.setId(1L);
        testWarehouse.setTenantId(1L);
        testWarehouse.setName("主仓库");
        testWarehouse.setAddress("北京市朝阳区");
        testWarehouse.setContact("张三");
        testWarehouse.setPhone("13800138000");
        testWarehouse.setIsDefault(1);
        testWarehouse.setProductCount(100);
        testWarehouse.setTotalStock(5000);
        testWarehouse.setStatus("active");
        testWarehouse.setCreatedAt(LocalDateTime.now());
    }

    @Test
    void testGetWarehouses_Success() {
        List<Warehouse> warehouses = Arrays.asList(testWarehouse);
        when(warehouseRepository.findByTenantId(1L)).thenReturn(warehouses);

        List<Warehouse> result = warehouseService.getWarehouses(1L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("主仓库", result.get(0).getName());
        verify(warehouseRepository).findByTenantId(1L);
    }

    @Test
    void testGetWarehouses_EmptyList() {
        when(warehouseRepository.findByTenantId(1L)).thenReturn(Arrays.asList());

        List<Warehouse> result = warehouseService.getWarehouses(1L);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    void testGetWarehouse_Success() {
        when(warehouseRepository.findById(1L)).thenReturn(Optional.of(testWarehouse));

        Warehouse result = warehouseService.getWarehouse(1L);

        assertNotNull(result);
        assertEquals("主仓库", result.getName());
        assertEquals("北京市朝阳区", result.getAddress());
    }

    @Test
    void testGetWarehouse_NotFound() {
        when(warehouseRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            warehouseService.getWarehouse(999L);
        });
    }

    @Test
    void testCreateWarehouse_Success() {
        Warehouse newWarehouse = new Warehouse();
        newWarehouse.setName("新仓库");
        newWarehouse.setAddress("上海市浦东新区");
        newWarehouse.setContact("李四");
        newWarehouse.setPhone("13900139000");

        when(warehouseRepository.save(any(Warehouse.class))).thenAnswer(invocation -> {
            Warehouse saved = invocation.getArgument(0);
            saved.setId(2L);
            return saved;
        });

        Warehouse result = warehouseService.createWarehouse(1L, newWarehouse);

        assertNotNull(result);
        assertEquals(2L, result.getId());
        assertEquals(1L, result.getTenantId());
        assertEquals("新仓库", result.getName());
        verify(warehouseRepository).save(any(Warehouse.class));
    }

    @Test
    void testUpdateWarehouse_Success() {
        Warehouse updateData = new Warehouse();
        updateData.setName("更新后的仓库");
        updateData.setAddress("深圳市南山区");
        updateData.setContact("王五");
        updateData.setPhone("13700137000");
        updateData.setStatus("inactive");

        when(warehouseRepository.findById(1L)).thenReturn(Optional.of(testWarehouse));
        when(warehouseRepository.save(any(Warehouse.class))).thenReturn(testWarehouse);

        Warehouse result = warehouseService.updateWarehouse(1L, updateData);

        assertNotNull(result);
        assertEquals("更新后的仓库", testWarehouse.getName());
        assertEquals("深圳市南山区", testWarehouse.getAddress());
        assertEquals("王五", testWarehouse.getContact());
        assertEquals("13700137000", testWarehouse.getPhone());
        assertEquals("inactive", testWarehouse.getStatus());
        verify(warehouseRepository).save(testWarehouse);
    }

    @Test
    void testUpdateWarehouse_NotFound() {
        Warehouse updateData = new Warehouse();
        updateData.setName("更新后的仓库");

        when(warehouseRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            warehouseService.updateWarehouse(999L, updateData);
        });
    }

    @Test
    void testDeleteWarehouse_Success() {
        doNothing().when(warehouseRepository).deleteById(1L);

        assertDoesNotThrow(() -> {
            warehouseService.deleteWarehouse(1L);
        });

        verify(warehouseRepository).deleteById(1L);
    }

    @Test
    void testGetWarehouseStats_Success() {
        Warehouse warehouse2 = new Warehouse();
        warehouse2.setId(2L);
        warehouse2.setTenantId(1L);
        warehouse2.setName("副仓库");

        List<Warehouse> warehouses = Arrays.asList(testWarehouse, warehouse2);
        when(warehouseRepository.findByTenantId(1L)).thenReturn(warehouses);
        when(inventoryRepository.getProductCountByTenantId(1L)).thenReturn(50);
        when(inventoryRepository.getTotalQuantityByTenantId(1L)).thenReturn(2500);

        Map<String, Object> result = warehouseService.getWarehouseStats(1L);

        assertNotNull(result);
        assertTrue(result.containsKey("warehouses"));
        assertEquals(2, ((List<?>)result.get("warehouses")).size());
        assertEquals(50, testWarehouse.getProductCount());
        assertEquals(2500, testWarehouse.getTotalStock());
    }

    @Test
    void testGetWarehouseStats_NullInventory() {
        List<Warehouse> warehouses = Arrays.asList(testWarehouse);
        when(warehouseRepository.findByTenantId(1L)).thenReturn(warehouses);
        when(inventoryRepository.getProductCountByTenantId(1L)).thenReturn(null);
        when(inventoryRepository.getTotalQuantityByTenantId(1L)).thenReturn(null);

        Map<String, Object> result = warehouseService.getWarehouseStats(1L);

        assertNotNull(result);
        assertEquals(0, testWarehouse.getProductCount());
        assertEquals(0, testWarehouse.getTotalStock());
    }
}
