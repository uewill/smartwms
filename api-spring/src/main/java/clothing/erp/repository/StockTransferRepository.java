package com.clothing.erp.repository;

import com.clothing.erp.entity.StockTransfer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StockTransferRepository extends JpaRepository<StockTransfer, Long> {

    @Query("SELECT t FROM StockTransfer t WHERE t.shopFrom.id = :shopId OR t.shopTo.id = :shopId ORDER BY t.createdAt DESC")
    List<StockTransfer> findByShopIdFromOrShopIdTo(@Param("shopId") Long shopId);

    @Query("SELECT MAX(t.transferNo) FROM StockTransfer t WHERE t.shopFrom.id = :shopId AND t.transferNo LIKE :prefix")
    String findMaxTransferNoByShopIdAndPrefix(@Param("shopId") Long shopId, @Param("prefix") String prefix);
}
