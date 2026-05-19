package com.clothing.erp.dto.product;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CreateProductRequest {

    @NotBlank(message = "款号不能为空")
    private String styleNo;

    @NotBlank(message = "商品名称不能为空")
    private String name;

    private String brand;

    @NotNull(message = "季节不能为空")
    private String season;

    private List<ColorDTO> colors;

    private List<SizeDTO> sizes;

    private List<SkuDTO> skus;

    private String oneHandCodePreset;

    private String imageUrl;

    private String thumbUrl;
}
