package com.clothing.erp.repository;

import com.clothing.erp.entity.ShopMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ShopMemberRepository extends JpaRepository<ShopMember, Long> {

    Optional<ShopMember> findByShopIdAndUserId(Long shopId, Long userId);
    List<ShopMember> findByUserId(Long userId);
    List<ShopMember> findByShopId(Long shopId);
}
