package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CacheSkuVO {

    private Long id;
    private String colorName;
    private String sizeName;
    private String barcode;
}
