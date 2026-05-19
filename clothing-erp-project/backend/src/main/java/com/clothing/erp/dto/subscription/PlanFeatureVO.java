package com.clothing.erp.dto.subscription;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlanFeatureVO {

    private String name;
    private Boolean basicEnabled;
    private Boolean premiumEnabled;
}
