package com.clothing.erp.repository;

import com.clothing.erp.entity.ProductColor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductColorRepository extends JpaRepository<ProductColor, Long> {

    List<ProductColor> findByProductId(Long productId);

    void deleteByProductId(Long productId);
}
