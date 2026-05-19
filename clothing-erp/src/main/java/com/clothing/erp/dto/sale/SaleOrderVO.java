package com.clothing.erp.dto.sale;

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
public class SaleOrderVO {

    private Long id;
    private String orderNo;
    private Long customerId;
    private String customerName;
    private String userName;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal actualAmount;
    private String paymentMethod;
    private String remark;
    private String orderType;
    private Long refOrderId;
    private String status;
    private List<SaleOrderItemVO> items;
    private LocalDateTime createdAt;
}
