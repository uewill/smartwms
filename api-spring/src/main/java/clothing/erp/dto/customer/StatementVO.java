package com.clothing.erp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StatementVO {

    private CustomerVO customerInfo;
    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal openingDebt;
    private List<DebtSaleOrderVO> creditOrders;
    private BigDecimal totalCredit;
    private List<PaymentRecordVO> paymentRecords;
    private BigDecimal totalPayment;
    private BigDecimal closingDebt;
}
