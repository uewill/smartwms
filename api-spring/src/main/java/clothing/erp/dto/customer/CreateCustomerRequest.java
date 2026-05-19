package com.clothing.erp.dto.customer;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateCustomerRequest {

    @NotBlank(message = "客户名称不能为空")
    private String name;

    private String phone;

    private String remark;
}
