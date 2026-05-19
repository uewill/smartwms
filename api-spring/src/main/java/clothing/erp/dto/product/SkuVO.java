package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkuVO {

    private Long id;
    private String colorName;
    private String sizeName;
    private String barcode;
    private BigDecimal retailPrice;
    private BigDecimal wholesalePrice;
    private BigDecimal purchasePrice;
    private Integer stockQty;
    private Integer stockWarningQty;
}
