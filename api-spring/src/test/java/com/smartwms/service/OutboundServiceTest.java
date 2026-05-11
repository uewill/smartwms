package com.smartwms.service;

import com.smartwms.dto.OutboundOrderRequest;
import com.smartwms.entity.Inventory;
import com.smartwms.entity.OutboundItem;
import com.smartwms.entity.OutboundOrder;
import com.smartwms.entity.Product;
import com.smartwms.repository.InventoryRepository;
import com.smartwms.repository.OutboundItemRepository;
import com.smartwms.repository.OutboundOrderRepository;
import com.smartwms.repository.ProductRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class OutboundServiceTest {

    @Mock
    private OutboundOrderRepository outboundOrderRepository;

    @Mock
    private OutboundItemRepository outboundItemRepository;

    @Mock
    private InventoryRepository inventoryRepository;

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private OutboundService outboundService;

    private OutboundOrder testOrder;
    private OutboundOrderRequest testRequest;
    private Product testProduct;
    private Inventory testInventory;

    @BeforeEach
    void setUp() {
        testOrder = new OutboundOrder();
        testOrder.setId(1L);
        testOrder.setOrderNo("OUT123456");
        testOrder.setTenantId(1L);
        testOrder.setWarehouseId(1L);
        testOrder.setWarehouseName("主仓库");
        testOrder.setCustomer("客户A");
        testOrder.setStatus("pending");
        testOrder.setTotalQuantity(50);
        testOrder.setTotalAmount(BigDecimal.valueOf(2500));

        OutboundOrderRequest.OutboundItemRequest itemReq = new OutboundOrderRequest.OutboundItemRequest();
        itemReq.setProductId(1L);
        itemReq.setProductName("测试商品");
        itemReq.setProductCode("P001");
        itemReq.setQuantity(50);
        itemReq.setCostPrice(BigDecimal.valueOf(50));

        testRequest = new OutboundOrderRequest();
        testRequest.setWarehouseId(1L);
        testRequest.setWarehouseName("主仓库");
        testRequest.setCustomer("客户A");
        testRequest.setOperatorId(1L);
        testRequest.setOperatorName("操作员");
        testRequest.setItems(Arrays.asList(itemReq));

        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setTenantId(1L);
        testProduct.setName("测试商品");
        testProduct.setCode("P001");
        testProduct.setStockQuantity(100);

        testInventory = new Inventory();
        testInventory.setId(1L);
        testInventory.setTenantId(1L);
        testInventory.setWarehouseId(1L);
        testInventory.setProductId(1L);
        testInventory.setProductName("测试商品");
        testInventory.setQuantity(100);
    }

    @Test
    void testGetOrders_Success() {
        List<OutboundOrder> orders = Arrays.asList(testOrder);
        when(outboundOrderRepository.findByTenantId(1L)).thenReturn(orders);

        List<OutboundOrder> result = outboundService.getOrders(1L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("OUT123456", result.get(0).getOrderNo());
        verify(outboundOrderRepository).findByTenantId(1L);
    }

    @Test
    void testGetOrder_Success() {
        OutboundItem item = new OutboundItem();
        item.setId(1L);
        item.setOrderId(1L);
        item.setProductName("测试商品");

        when(outboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(outboundItemRepository.findByOrderId(1L)).thenReturn(Arrays.asList(item));

        OutboundOrder result = outboundService.getOrder(1L);

        assertNotNull(result);
        assertEquals("OUT123456", result.getOrderNo());
        assertEquals(1, result.getItems().size());
    }

    @Test
    void testGetOrder_NotFound() {
        when(outboundOrderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            outboundService.getOrder(999L);
        });
    }

    @Test
    void testCreateOrder_Success() {
        when(outboundOrderRepository.save(any(OutboundOrder.class))).thenAnswer(invocation -> {
            OutboundOrder order = invocation.getArgument(0);
            order.setId(1L);
            return order;
        });
        when(outboundItemRepository.save(any(OutboundItem.class))).thenAnswer(invocation -> {
            OutboundItem item = invocation.getArgument(0);
            item.setId(1L);
            return item;
        });
        when(inventoryRepository.findByWarehouseIdAndProductId(1L, 1L)).thenReturn(Optional.of(testInventory));
        when(productRepository.findById(1L)).thenReturn(Optional.of(testProduct));
        when(outboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(outboundItemRepository.findByOrderId(1L)).thenReturn(Arrays.asList());

        OutboundOrder result = outboundService.createOrder(1L, testRequest);

        assertNotNull(result);
        verify(outboundOrderRepository).save(any(OutboundOrder.class));
        verify(outboundItemRepository, times(1)).save(any(OutboundItem.class));
    }

    @Test
    void testCreateOrder_InsufficientInventory() {
        testInventory.setQuantity(10);

        when(outboundOrderRepository.save(any(OutboundOrder.class))).thenAnswer(invocation -> {
            OutboundOrder order = invocation.getArgument(0);
            order.setId(1L);
            return order;
        });
        when(outboundItemRepository.save(any(OutboundItem.class))).thenAnswer(invocation -> {
            OutboundItem item = invocation.getArgument(0);
            item.setId(1L);
            return item;
        });
        when(inventoryRepository.findByWarehouseIdAndProductId(1L, 1L)).thenReturn(Optional.of(testInventory));

        assertThrows(RuntimeException.class, () -> {
            outboundService.createOrder(1L, testRequest);
        });
    }

    @Test
    void testUpdateStatus_Success() {
        when(outboundOrderRepository.findById(1L)).thenReturn(Optional.of(testOrder));
        when(outboundOrderRepository.save(any(OutboundOrder.class))).thenReturn(testOrder);

        OutboundOrder result = outboundService.updateStatus(1L, "completed");

        assertNotNull(result);
        assertEquals("completed", testOrder.getStatus());
        verify(outboundOrderRepository).save(testOrder);
    }

    @Test
    void testUpdateStatus_NotFound() {
        when(outboundOrderRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class, () -> {
            outboundService.updateStatus(999L, "completed");
        });
    }

    @Test
    void testDeleteOrder_Success() {
        doNothing().when(outboundItemRepository).deleteByOrderId(1L);
        doNothing().when(outboundOrderRepository).deleteById(1L);

        assertDoesNotThrow(() -> {
            outboundService.deleteOrder(1L);
        });

        verify(outboundItemRepository).deleteByOrderId(1L);
        verify(outboundOrderRepository).deleteById(1L);
    }
}
