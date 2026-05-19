package com.clothing.erp.repository;

import com.clothing.erp.entity.InventoryCheck;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface InventoryCheckRepository extends JpaRepository<InventoryCheck, Long> {

    List<InventoryCheck> findByShopId(Long shopId);

    Optional<InventoryCheck> findByIdAndShopId(Long id, Long shopId);

    @Query("SELECT MAX(c.checkNo) FROM InventoryCheck c WHERE c.shop.id = :shopId AND c.checkNo LIKE :prefix")
    String findMaxCheckNoByShopIdAndPrefix(@Param("shopId") Long shopId, @Param("prefix") String prefix);
}
