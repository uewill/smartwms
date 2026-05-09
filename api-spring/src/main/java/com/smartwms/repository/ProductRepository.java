package com.smartwms.repository;

import com.smartwms.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByTenantId(Long tenantId);
    Optional<Product> findByCode(String code);
    List<Product> findByTenantIdAndStatus(Long tenantId, String status);

    @Query("SELECT p FROM Product p WHERE p.tenantId = ?1 AND (p.name LIKE %?2% OR p.code LIKE %?2%)")
    List<Product> searchByKeyword(Long tenantId, String keyword);

    @Query("SELECT p FROM Product p WHERE p.tenantId = ?1 AND p.stockQuantity < p.warningStock AND p.warningStock > 0")
    List<Product> findLowStockByTenantId(Long tenantId);

    boolean existsByCode(String code);
}
