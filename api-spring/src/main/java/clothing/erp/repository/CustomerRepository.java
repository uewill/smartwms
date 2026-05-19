package com.clothing.erp.repository;

import com.clothing.erp.entity.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Optional<Customer> findByIdAndShopId(Long id, Long shopId);

    @Query("SELECT c FROM Customer c WHERE c.shop.id = :shopId " +
           "AND (:keyword IS NULL OR :keyword = '' OR c.name LIKE %:keyword% OR c.phone LIKE %:keyword%) " +
           "ORDER BY c.createdAt DESC")
    Page<Customer> findByShopIdWithKeyword(@Param("shopId") Long shopId,
                                           @Param("keyword") String keyword,
                                           Pageable pageable);

    @Query("SELECT c FROM Customer c WHERE c.shop.id = :shopId AND c.totalDebt > 0 " +
           "ORDER BY c.totalDebt DESC")
    List<Customer> findDebtCustomersByShopId(@Param("shopId") Long shopId);
}
