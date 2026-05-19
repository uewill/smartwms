package com.clothing.erp.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerDebtSummaryVO {

    private Long customerId;
    private String customerName;
    private BigDecimal totalDebt;
    private Integer orderCount;
}
