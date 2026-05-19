package com.clothing.erp.dto.purchase;

import lombok.Data;

import java.time.LocalDate;

@Data
public class PurchaseOrderQueryRequest {

    private String keyword;
    private String orderType;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer page = 0;
    private Integer size = 20;
}
