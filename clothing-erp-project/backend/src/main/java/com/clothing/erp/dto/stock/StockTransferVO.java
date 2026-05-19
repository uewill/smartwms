package com.clothing.erp.dto.stock;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StockTransferVO {

    private Long id;
    private String transferNo;
    private Long shopIdFrom;
    private String shopNameFrom;
    private Long shopIdTo;
    private String shopNameTo;
    private String status;
    private List<StockTransferItemVO> items;
    private LocalDateTime createdAt;
}
