package com.clothing.erp.controller;

import com.clothing.erp.common.Result;
import com.clothing.erp.config.CurrentUser;
import com.clothing.erp.dto.shop.*;
import com.clothing.erp.service.ShopService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shops")
@RequiredArgsConstructor
public class ShopController {

    private final ShopService shopService;

    @PostMapping
    public Result<ShopBrief> createShop(@CurrentUser Long userId,
                                        @Valid @RequestBody CreateShopRequest request) {
        ShopBrief shopBrief = shopService.createShop(userId, request);
        return Result.success(shopBrief);
    }

    @PostMapping("/join")
    public Result<ShopBrief> joinShop(@CurrentUser Long userId,
                                      @Valid @RequestBody JoinShopRequest request) {
        ShopBrief shopBrief = shopService.joinShop(userId, request);
        return Result.success(shopBrief);
    }

    @GetMapping("/my")
    public Result<List<ShopBrief>> getMyShops(@CurrentUser Long userId) {
        List<ShopBrief> shops = shopService.getMyShops(userId);
        return Result.success(shops);
    }

    @GetMapping("/{shopId}/members")
    public Result<List<ShopMemberDTO>> getShopMembers(@PathVariable Long shopId) {
        List<ShopMemberDTO> members = shopService.getShopMembers(shopId);
        return Result.success(members);
    }

    @PutMapping("/{shopId}/members/{memberId}")
    public Result<Void> updateMemberRole(@PathVariable Long shopId,
                                         @PathVariable Long memberId,
                                         @CurrentUser Long userId,
                                         @RequestBody UpdateMemberRequest request) {
        shopService.updateMemberRole(shopId, memberId, userId, request);
        return Result.success();
    }

    @PostMapping("/{shopId}/invite")
    public Result<String> generateInviteCode(@PathVariable Long shopId) {
        String inviteCode = shopService.generateInviteCode(shopId);
        return Result.success(inviteCode);
    }
}
