package com.smartwms.service;

import com.smartwms.dto.InboundOrderRequest;
import com.smartwms.entity.InboundItem;
import com.smartwms.entity.InboundOrder;
import com.smartwms.entity.Inventory;
import com.smartwms.entity.Product;
import com.smartwms.repository.InboundItemRepository;
import com.smartwms.repository.InboundOrderRepository;
import com.smartwms.repository.InventoryRepository;
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
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class InboundServiceTest {

    @Mock
    private InboundOrderRepository inboundOrderRepository;

    @Mock
    private InboundItemRepository inboundItemRepository;

    @Mock
    private InventoryRepository inventoryRepository;

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private InboundService inboundService;

    private InboundOrder testOrder;
    private InboundOrderRequest testRequest;
    private Product testProduct;
    private Inventory testInventory;

    @BeforeEach
    void setUp() {
        testOrder = new InboundOrder();
        testOrder.setId(1L);
        testOrder.setOrderNo("IN123456");
        testOrder.setTenantId(1L);
        testOrder.setWarehouseId(1L);
        testOrder.setWarehouseName("主仓库");
        testOrder.setSupplier("供应商A");
        testOrder.setStatus("pending");
        testOrder.setTotalQuantity(100);
        testOrder.setTotalAmount(BigDecimal.valueOf(5000));

        InboundOrderRequest.InboundItemRequest itemReq = new InboundOrderRequest.InboundItemRequest();
        itemReq.setProductId(1L);
        itemReq.setProductName("测试商品");
        itemReq.setProductCode("P001");
        itemReq.setQuantity(100);
        itemReq.setPrice(BigDecimal.valueOf(50));

        testRequest = new InboundOrderRequest();
        testRequest.setWarehouseId(1L);
        testRequest.setWarehouseName("主仓库");
        testRequest.setSupplier("供应商A");
        testRequest.setOperatorId(1L);
        testRequest.setOperatorName("操作员");
        testRequest.setItems(Arrays.asList(itemReq));

        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setTenantId(1L);
        testProduct.setName("测试商品");
        testProduct.setCode("P001");
        testProduct.setStockQuantity(50);

        testInventory = new Inventory();
        testInventory.setId(1L);
        testInventory.setTenantId(1L);
        testInventory.setWarehouseId(1L);
        testInventory.setProductId(1L);
        testInventory.setProductName("测试商品");
        testInventory.setQuantity(50);
    }

    @Test
    void testGetOrders_Success() {
        List<InboundOrder> orders = Arrays.asList(testOrder);
        when(inboundOrderRepository.findByTenantId(1L)).thenReturn(orders);

        List<InboundOrder> result = inboundService.getOrders(1L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("IN123456", result.get(0).getOrderNo());
        verify(inboundOrderRepository).findByTenantId(1L);
    }

    @Test
    void testGetOrder_Success() {
        InboundItem item = new InboundItem();
        item.setId(1L);
        item.setOrderId(1L);
        item.setProductName("测试商品");

        when(inboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(inboundItemRepository.findByOrderId(1L)).thenReturn(Arrays.asList(item));

        InboundOrder result = inboundService.getOrder(1L);

        assertNotNull(result);
        assertEquals("IN123456", result.getOrderNo());
        assertEquals(1, result.getItems().size());
    }

    @Test
    void testGetOrder_NotFound() {
        when(inboundOrderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            inboundService.getOrder(999L);
        });
    }

    @Test
    void testCreateOrder_Success() {
        when(inboundOrderRepository.save(any(InboundOrder.class))).thenAnswer(invocation -> {
            InboundOrder order = invocation.getArgument(0);
            order.setId(1L);
            return order;
        });
        when(inboundItemRepository.save(any(InboundItem.class))).thenAnswer(invocation -> {
            InboundItem item = invocation.getArgument(0);
            item.setId(1L);
            return item;
        });
        when(inventoryRepository.findByWarehouseIdAndProductId(1L, 1L)).thenReturn(Optional.of(testInventory));
        when(productRepository.findById(1L)).thenReturn(Optional.of(testProduct));
        when(inboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(inboundItemRepository.findByOrderId(1L)).thenReturn(Arrays.asList());

        InboundOrder result = inboundService.createOrder(1L, testRequest);

        assertNotNull(result);
        verify(inboundOrderRepository).save(any(InboundOrder.class));
        verify(inboundItemRepository, times(1)).save(any(InboundItem.class));
    }

    @Test
    void testUpdateStatus_Success() {
        when(inboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(inboundOrderRepository.save(any(InboundOrder.class))).thenReturn(testOrder);

        InboundOrder result = inboundService.updateStatus(1L, "completed");

        assertNotNull(result);
        assertEquals("completed", testOrder.getStatus());
        verify(inboundOrderRepository).save(testOrder);
    }

    @Test
    void testUpdateStatus_NotFound() {
        when(inboundOrderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            inboundService.updateStatus(999L, "completed");
        });
    }

    @Test
    void testDeleteOrder_Success() {
        doNothing().when(inboundItemRepository).deleteByOrderId(1L);
        doNothing().when(inboundOrderRepository).deleteById(1L);

        assertDoesNotThrow(() -> {
            inboundService.deleteOrder(1L);
        });

        verify(inboundItemRepository).deleteByOrderId(1L);
        verify(inboundOrderRepository).deleteById(1L);
    }
}
