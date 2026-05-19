package com.clothing.erp.dto.sale;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class SaleItemDTO {

    @NotNull(message = "SKU不能为空")
    private Long skuId;

    @NotNull(message = "数量不能为空")
    private Integer quantity;

    @NotNull(message = "单价不能为空")
    private BigDecimal unitPrice;

    private BigDecimal discountPrice;
}
