package com.clothing.erp.dto.sale;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class ReturnRequest {

    @NotNull(message = "原销售单ID不能为空")
    private Long refOrderId;

    @NotNull(message = "退货商品列表不能为空")
    private List<ReturnItemDTO> items;
}
