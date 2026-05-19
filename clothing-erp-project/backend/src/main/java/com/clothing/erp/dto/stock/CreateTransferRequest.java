package com.clothing.erp.dto.stock;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreateTransferRequest {

    @NotNull(message = "目标店铺不能为空")
    private Long shopIdTo;

    @NotNull(message = "调拨商品列表不能为空")
    private List<TransferItemDTO> items;
}
