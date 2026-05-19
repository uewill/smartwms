package com.clothing.erp.dto.purchase;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreatePurchaseOrderRequest {

    private String supplierName;

    private String remark;

    @NotNull(message = "商品列表不能为空")
    private List<PurchaseItemDTO> items;
}
