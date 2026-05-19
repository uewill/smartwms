package com.clothing.erp.dto.sale;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class CreateSaleOrderRequest {

    private Long customerId;

    @NotNull(message = "支付方式不能为空")
    private String paymentMethod;

    private String remark;

    @NotNull(message = "商品列表不能为空")
    private List<SaleItemDTO> items;

    private BigDecimal discountAmount;

    private BigDecimal totalAmount;
}
