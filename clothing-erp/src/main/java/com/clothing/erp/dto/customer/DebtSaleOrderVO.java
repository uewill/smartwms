package com.clothing.erp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DebtSaleOrderVO {

    private Long orderId;
    private String orderNo;
    private BigDecimal actualAmount;
    private BigDecimal unpaidAmount;
    private LocalDateTime createdAt;
}
