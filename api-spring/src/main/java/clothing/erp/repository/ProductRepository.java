package com.clothing.erp.repository;

import com.clothing.erp.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByShopId(Long shopId);

    Optional<Product> findByShopIdAndStyleNo(Long shopId, String styleNo);

    Optional<Product> findByIdAndShopId(Long id, Long shopId);

    @Query("SELECT p FROM Product p WHERE p.shop.id = :shopId " +
           "AND (:keyword IS NULL OR :keyword = '' OR p.styleNo LIKE %:keyword% OR p.name LIKE %:keyword%) " +
           "AND (:season IS NULL OR p.season = :season) " +
           "AND (:brand IS NULL OR :brand = '' OR p.brand = :brand) " +
           "ORDER BY p.createdAt DESC")
    Page<Product> findByShopIdWithFilter(@Param("shopId") Long shopId,
                                         @Param("keyword") String keyword,
                                         @Param("season") Product.Season season,
                                         @Param("brand") String brand,
                                         Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.shop.id = :shopId ORDER BY p.createdAt DESC")
    List<Product> findAllByShopId(@Param("shopId") Long shopId);
}
