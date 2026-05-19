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
public class CustomerVO {

    private Long id;
    private String name;
    private String phone;
    private String remark;
    private BigDecimal totalDebt;
    private LocalDateTime lastPurchaseAt;
    private LocalDateTime createdAt;
}
