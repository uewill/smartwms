package com.clothing.erp.dto.shop;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinShopRequest {

    @NotBlank(message = "邀请码不能为空")
    private String inviteCode;
}
