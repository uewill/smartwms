package com.clothing.erp.repository;

import com.clothing.erp.entity.ShopInvite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ShopInviteRepository extends JpaRepository<ShopInvite, Long> {

    Optional<ShopInvite> findByInviteCode(String inviteCode);
}
