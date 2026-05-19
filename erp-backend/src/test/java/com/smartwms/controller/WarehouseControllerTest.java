package com.smartwms.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.smartwms.entity.Warehouse;
import com.smartwms.middleware.AuthInterceptor;
import com.smartwms.service.WarehouseService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(WarehouseController.class)
class WarehouseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private WarehouseService warehouseService;

    @Autowired
    private ObjectMapper objectMapper;

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
    }

    @Test
    void testGetWarehouses_Success() throws Exception {
        List<Warehouse> warehouses = Arrays.asList(testWarehouse);
        when(warehouseService.getWarehouses(1L)).thenReturn(warehouses);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/warehouses")
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data[0].name").value("主仓库"));
    }

    @Test
    void testGetWarehouse_Success() throws Exception {
        when(warehouseService.getWarehouse(1L)).thenReturn(testWarehouse);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/warehouses/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.name").value("主仓库"))
                .andExpect(jsonPath("$.data.address").value("北京市朝阳区"));
    }

    @Test
    void testGetWarehouse_NotFound() throws Exception {
        when(warehouseService.getWarehouse(999L)).thenThrow(new RuntimeException("仓库不存在"));

        mockMvc.perform(MockMvcRequestBuilders.get("/api/warehouses/999"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(500));
    }

    @Test
    void testCreateWarehouse_Success() throws Exception {
        Warehouse newWarehouse = new Warehouse();
        newWarehouse.setName("新仓库");
        newWarehouse.setAddress("上海市浦东新区");
        newWarehouse.setContact("李四");
        newWarehouse.setPhone("13900139000");

        when(warehouseService.createWarehouse(eq(1L), any(Warehouse.class))).thenReturn(testWarehouse);

        mockMvc.perform(MockMvcRequestBuilders.post("/api/warehouses")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newWarehouse))
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data").exists());
    }

    @Test
    void testUpdateWarehouse_Success() throws Exception {
        Warehouse updateData = new Warehouse();
        updateData.setName("更新后的仓库");
        updateData.setAddress("深圳市南山区");

        when(warehouseService.updateWarehouse(eq(1L), any(Warehouse.class))).thenReturn(testWarehouse);

        mockMvc.perform(MockMvcRequestBuilders.put("/api/warehouses/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateData)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }

    @Test
    void testDeleteWarehouse_Success() throws Exception {
        doNothing().when(warehouseService).deleteWarehouse(1L);

        mockMvc.perform(MockMvcRequestBuilders.delete("/api/warehouses/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));

        verify(warehouseService).deleteWarehouse(1L);
    }

    @Test
    void testGetWarehouseStats_Success() throws Exception {
        Map<String, Object> stats = new HashMap<>();
        stats.put("warehouses", Arrays.asList(testWarehouse));

        when(warehouseService.getWarehouseStats(1L)).thenReturn(stats);

        mockMvc.perform(MockMvcRequestBuilders.get("/api/warehouses/stats")
                        .requestAttr(AuthInterceptor.TENANT_ID, 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0))
                .andExpect(jsonPath("$.data.warehouses").isArray());
    }
}
