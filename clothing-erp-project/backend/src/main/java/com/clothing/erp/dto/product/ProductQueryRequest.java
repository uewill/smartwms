package com.clothing.erp.dto.product;

import lombok.Data;

@Data
public class ProductQueryRequest {

    private String keyword;
    private String season;
    private String brand;
    private Integer page = 0;
    private Integer size = 20;
}
