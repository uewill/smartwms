package com.clothing.erp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentAllocationVO {

    private Long orderId;
    private String orderNo;
    private BigDecimal allocatedAmount;
}
