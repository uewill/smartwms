package com.clothing.erp.dto.stock;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StockSkuVO {

    private Long skuId;
    private String styleNo;
    private String productName;
    private String colorName;
    private String sizeName;
    private Integer stockQty;
    private Integer stockWarningQty;
    private Boolean isWarning;
}
