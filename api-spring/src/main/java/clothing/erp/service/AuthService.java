package com.clothing.erp.service;

import com.clothing.erp.common.ErrorCode;
import com.clothing.erp.dto.auth.LoginRequest;
import com.clothing.erp.dto.auth.LoginResponse;
import com.clothing.erp.dto.auth.RegisterRequest;
import com.clothing.erp.dto.shop.ShopBrief;
import com.clothing.erp.entity.Shop;
import com.clothing.erp.entity.ShopMember;
import com.clothing.erp.entity.SysUser;
import com.clothing.erp.exception.BusinessException;
import com.clothing.erp.repository.ShopMemberRepository;
import com.clothing.erp.repository.ShopRepository;
import com.clothing.erp.repository.SysUserRepository;
import com.clothing.erp.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserRepository sysUserRepository;
    private final ShopRepository shopRepository;
    private final ShopMemberRepository shopMemberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Transactional
    public void register(RegisterRequest request) {
        if (sysUserRepository.findByPhone(request.getPhone()).isPresent()) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS);
        }

        SysUser user = new SysUser();
        user.setPhone(request.getPhone());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname());
        SysUser savedUser = sysUserRepository.save(user);

        Shop shop = new Shop();
        shop.setName("我的店铺");
        shop.setOwner(savedUser);
        shop.setInviteCode(generateInviteCode());
        Shop savedShop = shopRepository.save(shop);

        ShopMember member = new ShopMember();
        member.setShop(savedShop);
        member.setUser(savedUser);
        member.setRole(ShopMember.MemberRole.OWNER);
        shopMemberRepository.save(member);
    }

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {
        SysUser user = sysUserRepository.findByPhone(request.getPhone())
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.PASSWORD_ERROR);
        }

        String token = jwtUtil.generateToken(user.getId(), user.getPhone());

        List<ShopBrief> shops = shopMemberRepository.findByUserId(user.getId()).stream()
                .map(membership -> ShopBrief.builder()
                        .id(membership.getShop().getId())
                        .name(membership.getShop().getName())
                        .role(membership.getRole().name())
                        .build())
                .toList();

        return LoginResponse.builder()
                .token(token)
                .userId(user.getId())
                .phone(user.getPhone())
                .nickname(user.getNickname())
                .shops(shops)
                .build();
    }

    private String generateInviteCode() {
        return UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }
}
