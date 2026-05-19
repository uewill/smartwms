package com.clothing.erp.dto.sale;

import lombok.Data;

import java.time.LocalDate;

@Data
public class SaleOrderQueryRequest {

    private String keyword;
    private String paymentMethod;
    private String orderType;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer page = 0;
    private Integer size = 20;
}
