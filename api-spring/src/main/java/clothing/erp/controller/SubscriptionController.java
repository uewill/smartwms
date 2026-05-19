package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.dto.subscription.PlanCompareVO;
import com.clothing.erp.dto.subscription.SubscriptionVO;
import com.clothing.erp.service.SubscriptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    @GetMapping("/api/shops/{shopId}/subscription")
    public Result<SubscriptionVO> getSubscription(@PathVariable Long shopId) {
        SubscriptionVO vo = subscriptionService.getSubscription(shopId);
        return Result.success(vo);
    }

    @GetMapping("/api/plans/compare")
    public Result<PlanCompareVO> getPlanCompare() {
        PlanCompareVO vo = subscriptionService.getPlanCompare();
        return Result.success(vo);
    }

    @GetMapping("/api/shops/{shopId}/subscription/check")
    public Result<Map<String, Object>> checkFeature(@PathVariable Long shopId,
                                                     @RequestParam String feature) {
        boolean enabled = subscriptionService.checkFeature(shopId, feature);
        return Result.success(Map.of("feature", feature, "enabled", enabled));
    }
}
