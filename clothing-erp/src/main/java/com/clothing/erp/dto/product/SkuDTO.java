package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkuDTO {

    private String colorName;
    private String sizeName;
    private String barcode;
    private BigDecimal retailPrice;
    private BigDecimal wholesalePrice;
    private BigDecimal purchasePrice;
}
