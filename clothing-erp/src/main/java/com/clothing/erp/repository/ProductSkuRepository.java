package com.clothing.erp.repository;

import com.clothing.erp.entity.Product;
import com.clothing.erp.entity.ProductSku;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductSkuRepository extends JpaRepository<ProductSku, Long> {

    List<ProductSku> findByProductId(Long productId);

    Optional<ProductSku> findByBarcode(String barcode);

    Optional<ProductSku> findByProductIdAndColorIdAndSizeId(Long productId, Long colorId, Long sizeId);

    void deleteByProductId(Long productId);

    @Query("SELECT s FROM ProductSku s JOIN s.product p " +
           "WHERE p.shop.id = :shopId " +
           "AND (:keyword IS NULL OR :keyword = '' OR p.styleNo LIKE %:keyword% OR p.name LIKE %:keyword%) " +
           "AND (:season IS NULL OR p.season = :season) " +
           "AND (:brand IS NULL OR :brand = '' OR p.brand = :brand) " +
           "AND (:warningOnly IS NULL OR :warningOnly = false OR (s.stockWarningQty > 0 AND s.stockQty <= s.stockWarningQty)) " +
           "ORDER BY p.styleNo ASC")
    Page<ProductSku> findByShopIdWithStockFilter(@Param("shopId") Long shopId,
                                                  @Param("keyword") String keyword,
                                                  @Param("season") Product.Season season,
                                                  @Param("brand") String brand,
                                                  @Param("warningOnly") Boolean warningOnly,
                                                  Pageable pageable);

    @Query("SELECT s FROM ProductSku s JOIN s.product p " +
           "WHERE p.shop.id = :shopId AND s.stockWarningQty > 0 AND s.stockQty <= s.stockWarningQty " +
           "ORDER BY p.styleNo ASC")
    List<ProductSku> findWarningByShopId(@Param("shopId") Long shopId);
}
