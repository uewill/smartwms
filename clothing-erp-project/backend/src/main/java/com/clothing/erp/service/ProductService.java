package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.product.*;
import com.clothing.erp.entity.Product;
import com.clothing.erp.entity.ProductColor;
import com.clothing.erp.entity.ProductSize;
import com.clothing.erp.entity.ProductSku;
import com.clothing.erp.entity.Shop;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.ProductColorRepository;
import com.clothing.erp.repository.ProductRepository;
import com.clothing.erp.repository.ProductSizeRepository;
import com.clothing.erp.repository.ProductSkuRepository;
import com.clothing.erp.repository.ShopRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final ProductColorRepository productColorRepository;
    private final ProductSizeRepository productSizeRepository;
    private final ProductSkuRepository productSkuRepository;
    private final ShopRepository shopRepository;

    @Transactional
    public ProductVO createProduct(Long shopId, CreateProductRequest request) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        productRepository.findByShopIdAndStyleNo(shopId, request.getStyleNo())
                .ifPresent(p -> {
                    throw new BusinessException(ErrorCode.PRODUCT_STYLE_NO_EXISTS);
                });

        Product product = new Product();
        product.setShop(shop);
        product.setStyleNo(request.getStyleNo());
        product.setName(request.getName());
        product.setBrand(request.getBrand());
        if (request.getSeason() != null) {
            product.setSeason(Product.Season.valueOf(request.getSeason()));
        }
        product.setImageUrl(request.getImageUrl());
        product.setThumbUrl(request.getThumbUrl());
        product.setOneHandCodePreset(request.getOneHandCodePreset());

        List<ProductColor> colors = new ArrayList<>();
        if (request.getColors() != null) {
            for (ColorDTO dto : request.getColors()) {
                ProductColor color = new ProductColor();
                color.setProduct(product);
                color.setColorName(dto.getColorName());
                color.setColorCode(dto.getColorCode());
                colors.add(color);
            }
        }
        product.setColors(colors);

        List<ProductSize> sizes = new ArrayList<>();
        if (request.getSizes() != null) {
            for (SizeDTO dto : request.getSizes()) {
                ProductSize size = new ProductSize();
                size.setProduct(product);
                size.setSizeName(dto.getSizeName());
                size.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);
                sizes.add(size);
            }
        }
        product.setSizes(sizes);

        Product savedProduct = productRepository.save(product);

        List<ProductSku> skus = buildSkuMatrix(savedProduct, colors, sizes, request.getSkus());
        List<ProductSku> savedSkus = productSkuRepository.saveAll(skus);
        savedProduct.setSkus(savedSkus);

        return toProductVO(savedProduct);
    }

    @Transactional
    public ProductVO updateProduct(Long shopId, Long productId, CreateProductRequest request) {
        Product product = productRepository.findByIdAndShopId(productId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        if (!product.getStyleNo().equals(request.getStyleNo())) {
            productRepository.findByShopIdAndStyleNo(shopId, request.getStyleNo())
                    .ifPresent(p -> {
                        throw new BusinessException(ErrorCode.PRODUCT_STYLE_NO_EXISTS);
                    });
        }

        product.setStyleNo(request.getStyleNo());
        product.setName(request.getName());
        product.setBrand(request.getBrand());
        if (request.getSeason() != null) {
            product.setSeason(Product.Season.valueOf(request.getSeason()));
        }
        product.setImageUrl(request.getImageUrl());
        product.setThumbUrl(request.getThumbUrl());
        product.setOneHandCodePreset(request.getOneHandCodePreset());

        product.getColors().clear();
        product.getSizes().clear();
        product.getSkus().clear();

        List<ProductColor> colors = new ArrayList<>();
        if (request.getColors() != null) {
            for (ColorDTO dto : request.getColors()) {
                ProductColor color = new ProductColor();
                color.setProduct(product);
                color.setColorName(dto.getColorName());
                color.setColorCode(dto.getColorCode());
                colors.add(color);
                product.getColors().add(color);
            }
        }

        List<ProductSize> sizes = new ArrayList<>();
        if (request.getSizes() != null) {
            for (SizeDTO dto : request.getSizes()) {
                ProductSize size = new ProductSize();
                size.setProduct(product);
                size.setSizeName(dto.getSizeName());
                size.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);
                sizes.add(size);
                product.getSizes().add(size);
            }
        }

        Product savedProduct = productRepository.saveAndFlush(product);

        List<ProductSku> skus = buildSkuMatrix(savedProduct, colors, sizes, request.getSkus());
        savedProduct.getSkus().addAll(skus);
        productSkuRepository.saveAll(skus);

        return toProductVO(savedProduct);
    }

    @Transactional(readOnly = true)
    public ProductVO getProduct(Long shopId, Long productId) {
        Product product = productRepository.findByIdAndShopId(productId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));
        return toProductVO(product);
    }

    @Transactional(readOnly = true)
    public Page<ProductListVO> listProducts(Long shopId, ProductQueryRequest query) {
        Pageable pageable = PageRequest.of(query.getPage(), query.getSize());
        Product.Season season = null;
        if (query.getSeason() != null && !query.getSeason().isEmpty()) {
            season = Product.Season.valueOf(query.getSeason());
        }
        Page<Product> page = productRepository.findByShopIdWithFilter(
                shopId, query.getKeyword(), season, query.getBrand(), pageable);
        return page.map(this::toProductListVO);
    }

    @Transactional
    public void deleteProduct(Long shopId, Long productId) {
        Product product = productRepository.findByIdAndShopId(productId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));
        productRepository.delete(product);
    }

    @Transactional
    public void batchSetPrice(Long shopId, Long productId, BatchPriceRequest request) {
        Product product = productRepository.findByIdAndShopId(productId, shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PRODUCT_NOT_FOUND));

        List<ProductSku> skus = productSkuRepository.findByProductId(productId);
        for (ProductSku sku : skus) {
            if (request.getRetailPrice() != null) {
                sku.setRetailPrice(request.getRetailPrice());
            }
            if (request.getWholesalePrice() != null) {
                sku.setWholesalePrice(request.getWholesalePrice());
            }
            if (request.getPurchasePrice() != null) {
                sku.setPurchasePrice(request.getPurchasePrice());
            }
        }
        productSkuRepository.saveAll(skus);
    }

    @Transactional(readOnly = true)
    public SkuVO getSkuByBarcode(String barcode) {
        ProductSku sku = productSkuRepository.findByBarcode(barcode)
                .orElseThrow(() -> new BusinessException(ErrorCode.SKU_NOT_FOUND));
        return toSkuVO(sku);
    }

    @Transactional(readOnly = true)
    public List<CacheProductVO> getCachedProducts(Long shopId) {
        List<Product> products = productRepository.findAllByShopId(shopId);
        return products.stream().map(this::toCacheProductVO).toList();
    }

    private List<ProductSku> buildSkuMatrix(Product product, List<ProductColor> colors,
                                            List<ProductSize> sizes, List<SkuDTO> skuDTOs) {
        Map<String, SkuDTO> skuMap = new java.util.HashMap<>();
        if (skuDTOs != null) {
            for (SkuDTO dto : skuDTOs) {
                String key = dto.getColorName() + "|" + dto.getSizeName();
                skuMap.put(key, dto);
            }
        }

        List<ProductSku> skus = new ArrayList<>();
        for (ProductColor color : colors) {
            for (ProductSize size : sizes) {
                ProductSku sku = new ProductSku();
                sku.setProduct(product);
                sku.setColor(color);
                sku.setSize(size);

                String key = color.getColorName() + "|" + size.getSizeName();
                SkuDTO dto = skuMap.get(key);
                if (dto != null) {
                    sku.setBarcode(dto.getBarcode());
                    sku.setRetailPrice(dto.getRetailPrice());
                    sku.setWholesalePrice(dto.getWholesalePrice());
                    sku.setPurchasePrice(dto.getPurchasePrice());
                }

                sku.setStockQty(0);
                sku.setStockWarningQty(0);
                skus.add(sku);
            }
        }
        return skus;
    }

    private ProductVO toProductVO(Product product) {
        List<ColorDTO> colors = product.getColors() != null
                ? product.getColors().stream()
                    .map(c -> new ColorDTO(c.getColorName(), c.getColorCode()))
                    .toList()
                : List.of();

        List<SizeDTO> sizes = product.getSizes() != null
                ? product.getSizes().stream()
                    .map(s -> new SizeDTO(s.getSizeName(), s.getSortOrder()))
                    .toList()
                : List.of();

        List<SkuVO> skus = product.getSkus() != null
                ? product.getSkus().stream()
                    .map(this::toSkuVO)
                    .toList()
                : List.of();

        return ProductVO.builder()
                .id(product.getId())
                .styleNo(product.getStyleNo())
                .name(product.getName())
                .brand(product.getBrand())
                .season(product.getSeason() != null ? product.getSeason().name() : null)
                .imageUrl(product.getImageUrl())
                .thumbUrl(product.getThumbUrl())
                .oneHandCodePreset(product.getOneHandCodePreset())
                .colors(colors)
                .sizes(sizes)
                .skus(skus)
                .build();
    }

    private SkuVO toSkuVO(ProductSku sku) {
        return SkuVO.builder()
                .id(sku.getId())
                .colorName(sku.getColor() != null ? sku.getColor().getColorName() : null)
                .sizeName(sku.getSize() != null ? sku.getSize().getSizeName() : null)
                .barcode(sku.getBarcode())
                .retailPrice(sku.getRetailPrice())
                .wholesalePrice(sku.getWholesalePrice())
                .purchasePrice(sku.getPurchasePrice())
                .stockQty(sku.getStockQty())
                .stockWarningQty(sku.getStockWarningQty())
                .build();
    }

    private ProductListVO toProductListVO(Product product) {
        int totalStock = 0;
        if (product.getSkus() != null) {
            totalStock = product.getSkus().stream()
                    .mapToInt(s -> s.getStockQty() != null ? s.getStockQty() : 0)
                    .sum();
        }

        return ProductListVO.builder()
                .id(product.getId())
                .styleNo(product.getStyleNo())
                .name(product.getName())
                .brand(product.getBrand())
                .season(product.getSeason() != null ? product.getSeason().name() : null)
                .thumbUrl(product.getThumbUrl())
                .totalStock(totalStock)
                .build();
    }

    private CacheProductVO toCacheProductVO(Product product) {
        List<ColorDTO> colors = product.getColors() != null
                ? product.getColors().stream()
                    .map(c -> new ColorDTO(c.getColorName(), c.getColorCode()))
                    .toList()
                : List.of();

        List<SizeDTO> sizes = product.getSizes() != null
                ? product.getSizes().stream()
                    .map(s -> new SizeDTO(s.getSizeName(), s.getSortOrder()))
                    .toList()
                : List.of();

        List<CacheSkuVO> skus = product.getSkus() != null
                ? product.getSkus().stream()
                    .map(s -> CacheSkuVO.builder()
                            .id(s.getId())
                            .colorName(s.getColor() != null ? s.getColor().getColorName() : null)
                            .sizeName(s.getSize() != null ? s.getSize().getSizeName() : null)
                            .barcode(s.getBarcode())
                            .build())
                    .toList()
                : List.of();

        return CacheProductVO.builder()
                .id(product.getId())
                .styleNo(product.getStyleNo())
                .name(product.getName())
                .thumbUrl(product.getThumbUrl())
                .colors(colors)
                .sizes(sizes)
                .skus(skus)
                .build();
    }
}
