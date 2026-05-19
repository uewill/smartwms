package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SizeDTO {

    private String sizeName;
    private Integer sortOrder;
}
