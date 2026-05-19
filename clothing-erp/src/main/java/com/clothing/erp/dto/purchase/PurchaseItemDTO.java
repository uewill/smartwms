package com.clothing.erp.dto.purchase;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class PurchaseItemDTO {

    @NotNull(message = "SKU不能为空")
    private Long skuId;

    @NotNull(message = "数量不能为空")
    private Integer quantity;

    @NotNull(message = "拿货价不能为空")
    private BigDecimal unitPrice;
}
