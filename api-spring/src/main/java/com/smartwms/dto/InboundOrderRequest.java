package com.smartwms.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class InboundOrderRequest {
    private Long warehouseId;
    private String warehouseName;
    private String supplier;
    private String remark;
    private Long operatorId;
    private String operatorName;
    private java.util.List<InboundItemRequest> items;

    @Data
    public static class InboundItemRequest {
        private Long productId;
        private String productName;
        private String productCode;
        private Integer quantity;
        private BigDecimal price;
    }
}
