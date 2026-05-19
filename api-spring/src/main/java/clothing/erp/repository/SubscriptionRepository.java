package com.clothing.erp.repository;

import com.clothing.erp.entity.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {

    Optional<Subscription> findByShopIdAndStatus(Long shopId, Subscription.SubscriptionStatus status);

    Optional<Subscription> findByShopId(Long shopId);
}
