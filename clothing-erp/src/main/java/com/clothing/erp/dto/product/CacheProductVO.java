package com.clothing.erp.dto.product;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CacheProductVO {

    private Long id;
    private String styleNo;
    private String name;
    private String thumbUrl;
    private List<ColorDTO> colors;
    private List<SizeDTO> sizes;
    private List<CacheSkuVO> skus;
}
