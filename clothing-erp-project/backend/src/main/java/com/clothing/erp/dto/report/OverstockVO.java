package com.clothing.erp.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OverstockVO {

    private Long skuId;
    private String styleNo;
    private String productName;
    private String colorName;
    private String sizeName;
    private Integer stockQty;
    private LocalDate lastSaleDate;
    private Integer turnoverDays;
}
