package com.clothing.erp.dto.stock;

import lombok.Data;

@Data
public class StockQueryRequest {

    private String keyword;
    private String season;
    private String brand;
    private Boolean warningOnly;
    private Integer page = 0;
    private Integer size = 20;
}
