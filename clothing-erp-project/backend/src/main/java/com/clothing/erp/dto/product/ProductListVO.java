package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductListVO {

    private Long id;
    private String styleNo;
    private String name;
    private String brand;
    private String season;
    private String thumbUrl;
    private Integer totalStock;
}
