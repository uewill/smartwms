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
public class ProductVO {

    private Long id;
    private String styleNo;
    private String name;
    private String brand;
    private String season;
    private String imageUrl;
    private String thumbUrl;
    private String oneHandCodePreset;
    private List<ColorDTO> colors;
    private List<SizeDTO> sizes;
    private List<SkuVO> skus;
}
