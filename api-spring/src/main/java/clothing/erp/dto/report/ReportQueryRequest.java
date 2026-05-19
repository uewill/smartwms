package com.clothing.erp.dto.report;

import lombok.Data;

import java.time.LocalDate;

@Data
public class ReportQueryRequest {

    private LocalDate startDate;
    private LocalDate endDate;
}
