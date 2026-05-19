package com.clothing.erp.dto.purchase;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class ReturnPurchaseRequest {

    @NotNull(message = "原采购单不能为空")
    private Long refOrderId;

    @NotNull(message = "退货商品列表不能为空")
    private List<PurchaseItemDTO> items;

    private String remark;
}
