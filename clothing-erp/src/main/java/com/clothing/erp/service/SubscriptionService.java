package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.subscription.*;
import com.clothing.erp.entity.Shop;
import com.clothing.erp.entity.Subscription;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.ShopRepository;
import com.clothing.erp.repository.SubscriptionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final ShopRepository shopRepository;

    private static final Map<String, FeatureDef> FEATURE_MAP = new LinkedHashMap<>();

    static {
        FEATURE_MAP.put("BLUETOOTH_PRINT", new FeatureDef("蓝牙打印", false, true));
        FEATURE_MAP.put("CUSTOMER_STATEMENT", new FeatureDef("客户对账单", false, true));
        FEATURE_MAP.put("ADVANCED_REPORT", new FeatureDef("高级报表", false, true));
        FEATURE_MAP.put("DATA_EXPORT", new FeatureDef("数据导出", false, true));
        FEATURE_MAP.put("STOCK_WARNING_PUSH", new FeatureDef("库存预警推送", false, true));
        FEATURE_MAP.put("MULTI_SHOP", new FeatureDef("多店管理(>2)", false, true));
        FEATURE_MAP.put("MULTI_SHOP_REPORT", new FeatureDef("多店聚合报表", false, true));
    }

    @Transactional(readOnly = true)
    public SubscriptionVO getSubscription(Long shopId) {
        Subscription subscription = subscriptionRepository.findByShopId(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND, "店铺订阅信息不存在"));

        List<FeatureVO> features = buildFeatureList(subscription.getPlanType());

        return SubscriptionVO.builder()
                .id(subscription.getId())
                .planType(subscription.getPlanType().name())
                .startDate(subscription.getStartDate())
                .endDate(subscription.getEndDate())
                .status(subscription.getStatus().name())
                .maxShops(subscription.getMaxShops())
                .features(features)
                .build();
    }

    public PlanCompareVO getPlanCompare() {
        List<PlanFeatureVO> features = new ArrayList<>();
        for (Map.Entry<String, FeatureDef> entry : FEATURE_MAP.entrySet()) {
            FeatureDef def = entry.getValue();
            features.add(PlanFeatureVO.builder()
                    .name(def.name)
                    .basicEnabled(def.basicEnabled)
                    .premiumEnabled(def.premiumEnabled)
                    .build());
        }
        return PlanCompareVO.builder().features(features).build();
    }

    @Transactional(readOnly = true)
    public boolean checkFeature(Long shopId, String featureCode) {
        Subscription subscription = subscriptionRepository.findByShopId(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND, "店铺订阅信息不存在"));

        if (subscription.getStatus() != Subscription.SubscriptionStatus.ACTIVE) {
            return false;
        }

        FeatureDef featureDef = FEATURE_MAP.get(featureCode);
        if (featureDef == null) {
            return false;
        }

        if (subscription.getPlanType() == Subscription.PlanType.PREMIUM) {
            return featureDef.premiumEnabled;
        }
        return featureDef.basicEnabled;
    }

    @Transactional
    public void initSubscription(Long shopId) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        Optional<Subscription> existing = subscriptionRepository.findByShopId(shopId);
        if (existing.isPresent()) {
            return;
        }

        Subscription subscription = new Subscription();
        subscription.setShop(shop);
        subscription.setPlanType(Subscription.PlanType.BASIC);
        subscription.setStartDate(LocalDate.now());
        subscription.setEndDate(LocalDate.now().plusYears(100));
        subscription.setStatus(Subscription.SubscriptionStatus.ACTIVE);
        subscription.setMaxShops(1);
        subscriptionRepository.save(subscription);
    }

    @Transactional(readOnly = true)
    public void validatePremium(Long shopId) {
        Subscription subscription = subscriptionRepository.findByShopId(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND, "店铺订阅信息不存在"));

        if (subscription.getStatus() != Subscription.SubscriptionStatus.ACTIVE) {
            throw new BusinessException(ErrorCode.PREMIUM_REQUIRED);
        }
        if (subscription.getPlanType() != Subscription.PlanType.PREMIUM) {
            throw new BusinessException(ErrorCode.PREMIUM_REQUIRED);
        }
    }

    private List<FeatureVO> buildFeatureList(Subscription.PlanType planType) {
        List<FeatureVO> features = new ArrayList<>();
        for (Map.Entry<String, FeatureDef> entry : FEATURE_MAP.entrySet()) {
            FeatureDef def = entry.getValue();
            boolean enabled = planType == Subscription.PlanType.PREMIUM
                    ? def.premiumEnabled : def.basicEnabled;
            features.add(FeatureVO.builder()
                    .name(def.name)
                    .enabled(enabled)
                    .build());
        }
        return features;
    }

    private static class FeatureDef {
        String name;
        boolean basicEnabled;
        boolean premiumEnabled;

        FeatureDef(String name, boolean basicEnabled, boolean premiumEnabled) {
            this.name = name;
            this.basicEnabled = basicEnabled;
            this.premiumEnabled = premiumEnabled;
        }
    }
}
