package com.clothing.erp.dto.purchase;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrderVO {

    private Long id;
    private String orderNo;
    private String supplierName;
    private BigDecimal totalAmount;
    private String remark;
    private String orderType;
    private String status;
    private List<PurchaseOrderItemVO> items;
    private LocalDateTime createdAt;
}
