package com.clothing.erp.dto.report;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HotProductVO {

    private Long productId;
    private String styleNo;
    private String productName;
    private String thumbUrl;
    private Integer salesQuantity;
    private BigDecimal salesAmount;
}
