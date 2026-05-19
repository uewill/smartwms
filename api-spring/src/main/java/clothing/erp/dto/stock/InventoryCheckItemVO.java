package com.clothing.erp.dto.stock;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InventoryCheckItemVO {

    private Long id;
    private Long skuId;
    private String styleNo;
    private String colorName;
    private String sizeName;
    private Integer systemQty;
    private Integer actualQty;
    private Integer diffQty;
}
