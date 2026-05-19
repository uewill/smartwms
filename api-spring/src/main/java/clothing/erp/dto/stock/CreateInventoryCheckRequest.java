package com.clothing.erp.dto.stock;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreateInventoryCheckRequest {

    @NotNull(message = "盘点范围不能为空")
    private String scopeType;

    private String scopeValue;

    @NotNull(message = "盘点明细不能为空")
    private List<InventoryCheckItemDTO> items;
}
