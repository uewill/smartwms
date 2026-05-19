package com.clothing.erp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerDebtDetailVO {

    private CustomerVO customerInfo;
    private List<DebtSaleOrderVO> unpaidOrders;
    private List<PaymentRecordVO> paymentRecords;
}
