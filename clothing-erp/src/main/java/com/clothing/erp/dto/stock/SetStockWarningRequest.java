package com.clothing.erp.dto.stock;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SetStockWarningRequest {

    @NotNull(message = "SKU不能为空")
    private Long skuId;

    @NotNull(message = "预警数量不能为空")
    private Integer stockWarningQty;
}
