package com.clothing.erp.dto.customer;

import lombok.Data;

@Data
public class CustomerQueryRequest {

    private String keyword;
    private Integer page = 0;
    private Integer size = 20;
}
