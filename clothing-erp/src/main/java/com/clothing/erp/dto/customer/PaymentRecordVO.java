package com.clothing.erp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRecordVO {

    private Long id;
    private BigDecimal amount;
    private String remark;
    private LocalDateTime createdAt;
    private List<PaymentAllocationVO> allocations;
}
