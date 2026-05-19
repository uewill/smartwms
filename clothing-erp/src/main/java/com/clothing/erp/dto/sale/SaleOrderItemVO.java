package com.clothing.erp.dto.sale;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SaleOrderItemVO {

    private Long id;
    private Long skuId;
    private String styleNo;
    private String colorName;
    private String sizeName;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private BigDecimal purchasePrice;
}
