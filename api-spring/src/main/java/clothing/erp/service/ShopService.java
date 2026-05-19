package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.shop.*;
import com.clothing.erp.entity.Shop;
import com.clothing.erp.entity.ShopInvite;
import com.clothing.erp.entity.ShopMember;
import com.clothing.erp.entity.SysUser;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.ShopInviteRepository;
import com.clothing.erp.repository.ShopMemberRepository;
import com.clothing.erp.repository.ShopRepository;
import com.clothing.erp.repository.SysUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShopService {

    private final ShopRepository shopRepository;
    private final ShopMemberRepository shopMemberRepository;
    private final ShopInviteRepository shopInviteRepository;
    private final SysUserRepository sysUserRepository;

    @Transactional
    public ShopBrief createShop(Long userId, CreateShopRequest request) {
        SysUser user = sysUserRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        Shop shop = new Shop();
        shop.setName(request.getName());
        shop.setAddress(request.getAddress());
        shop.setOwner(user);
        shop.setInviteCode(generateInviteCode());
        Shop savedShop = shopRepository.save(shop);

        ShopMember member = new ShopMember();
        member.setShop(savedShop);
        member.setUser(user);
        member.setRole(ShopMember.MemberRole.OWNER);
        shopMemberRepository.save(member);

        return ShopBrief.builder()
                .id(savedShop.getId())
                .name(savedShop.getName())
                .role(ShopMember.MemberRole.OWNER.name())
                .build();
    }

    @Transactional
    public ShopBrief joinShop(Long userId, JoinShopRequest request) {
        ShopInvite invite = shopInviteRepository.findByInviteCode(request.getInviteCode())
                .orElseThrow(() -> new BusinessException(ErrorCode.INVITE_CODE_INVALID));

        if (invite.getExpireAt().isBefore(LocalDateTime.now())) {
            throw new BusinessException(ErrorCode.INVITE_CODE_EXPIRED);
        }

        Shop shop = invite.getShop();

        shopMemberRepository.findByShopIdAndUserId(shop.getId(), userId)
                .ifPresent(m -> {
                    throw new BusinessException(ErrorCode.ALREADY_MEMBER);
                });

        SysUser user = sysUserRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        ShopMember member = new ShopMember();
        member.setShop(shop);
        member.setUser(user);
        member.setRole(ShopMember.MemberRole.STAFF);
        shopMemberRepository.save(member);

        return ShopBrief.builder()
                .id(shop.getId())
                .name(shop.getName())
                .role(ShopMember.MemberRole.STAFF.name())
                .build();
    }

    @Transactional(readOnly = true)
    public List<ShopBrief> getMyShops(Long userId) {
        return shopMemberRepository.findByUserId(userId).stream()
                .map(membership -> ShopBrief.builder()
                        .id(membership.getShop().getId())
                        .name(membership.getShop().getName())
                        .role(membership.getRole().name())
                        .build())
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ShopMemberDTO> getShopMembers(Long shopId) {
        return shopMemberRepository.findByShopId(shopId).stream()
                .map(member -> ShopMemberDTO.builder()
                        .id(member.getId())
                        .userId(member.getUser().getId())
                        .nickname(member.getUser().getNickname())
                        .phone(member.getUser().getPhone())
                        .role(member.getRole().name())
                        .permissions(member.getPermissions())
                        .build())
                .toList();
    }

    @Transactional
    public void updateMemberRole(Long shopId, Long memberId, Long currentUserId, UpdateMemberRequest request) {
        ShopMember currentMember = shopMemberRepository.findByShopIdAndUserId(shopId, currentUserId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PERMISSION_DENIED));

        if (currentMember.getRole() != ShopMember.MemberRole.OWNER
                && currentMember.getRole() != ShopMember.MemberRole.ADMIN) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED);
        }

        ShopMember targetMember = shopMemberRepository.findById(memberId)
                .orElseThrow(() -> new BusinessException(ErrorCode.MEMBER_NOT_FOUND));

        if (!targetMember.getShop().getId().equals(shopId)) {
            throw new BusinessException(ErrorCode.MEMBER_NOT_FOUND);
        }

        if (targetMember.getRole() == ShopMember.MemberRole.OWNER) {
            throw new BusinessException(ErrorCode.PERMISSION_DENIED, "不能修改OWNER角色");
        }

        if (request.getRole() != null) {
            targetMember.setRole(ShopMember.MemberRole.valueOf(request.getRole()));
        }
        if (request.getPermissions() != null) {
            targetMember.setPermissions(request.getPermissions());
        }
        shopMemberRepository.save(targetMember);
    }

    @Transactional
    public String generateInviteCode(Long shopId) {
        Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SHOP_NOT_FOUND));

        String code = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();

        ShopInvite invite = new ShopInvite();
        invite.setShop(shop);
        invite.setInviteCode(code);
        invite.setExpireAt(LocalDateTime.now().plusDays(7));
        shopInviteRepository.save(invite);

        shop.setInviteCode(code);
        shopRepository.save(shop);

        return code;
    }

    private String generateInviteCode() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }
}
