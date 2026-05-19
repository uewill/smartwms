package com.clothing.erp.dto.product;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class BatchPriceRequest {

    @NotNull(message = "商品ID不能为空")
    private Long productId;

    private BigDecimal retailPrice;
    private BigDecimal wholesalePrice;
    private BigDecimal purchasePrice;
}
