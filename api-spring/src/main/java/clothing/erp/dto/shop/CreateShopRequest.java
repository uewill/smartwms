package com.clothing.erp.dto.shop;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateShopRequest {

    @NotBlank(message = "店铺名称不能为空")
    private String name;

    private String address;
}
