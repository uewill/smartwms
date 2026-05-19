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
public class TodaySummaryVO {

    private BigDecimal todaySales;
    private BigDecimal todayProfit;
    private Integer todayOrderCount;
}
