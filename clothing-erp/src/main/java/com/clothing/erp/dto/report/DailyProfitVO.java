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
public class DailyProfitVO {

    private String date;
    private BigDecimal revenue;
    private BigDecimal cost;
    private BigDecimal profit;
}
