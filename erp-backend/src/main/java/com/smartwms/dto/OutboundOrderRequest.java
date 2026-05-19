package com.smartwms.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class OutboundOrderRequest {
    private Long warehouseId;
    private String warehouseName;
    private String customer;
    private String remark;
    private Long operatorId;
    private String operatorName;
    private java.util.List<OutboundItemRequest> items;

    @Data
    public static class OutboundItemRequest {
        private Long productId;
        private String productName;
        private String productCode;
        private Integer quantity;
        private BigDecimal costPrice;
    }
}
