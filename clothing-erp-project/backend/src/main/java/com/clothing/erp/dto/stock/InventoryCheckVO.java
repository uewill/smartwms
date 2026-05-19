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
public class InventoryCheckVO {

    private Long id;
    private String checkNo;
    private String scopeType;
    private String scopeValue;
    private String status;
    private List<InventoryCheckItemVO> items;
    private LocalDateTime createdAt;
}
