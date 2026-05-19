package com.clothing.erp.dto.customer;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class CollectDebtRequest {

    @NotNull(message = "客户ID不能为空")
    private Long customerId;

    @NotNull(message = "还款金额不能为空")
    private BigDecimal amount;

    private String remark;
}
