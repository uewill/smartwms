package com.clothing.erp.dto.stock;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InventoryCheckItemDTO {

    @NotNull(message = "SKU不能为空")
    private Long skuId;

    @NotNull(message = "实盘数量不能为空")
    private Integer actualQty;
}
