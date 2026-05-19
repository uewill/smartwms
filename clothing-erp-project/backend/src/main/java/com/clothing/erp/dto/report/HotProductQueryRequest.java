package com.clothing.erp.dto.report;

import lombok.Data;

import java.time.LocalDate;

@Data
public class HotProductQueryRequest {

    private LocalDate startDate;
    private LocalDate endDate;
    private Integer top = 20;
}
