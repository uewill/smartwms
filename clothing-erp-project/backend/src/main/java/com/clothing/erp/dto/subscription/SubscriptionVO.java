package com.clothing.erp.dto.subscription;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubscriptionVO {

    private Long id;
    private String planType;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;
    private Integer maxShops;
    private List<FeatureVO> features;
}
