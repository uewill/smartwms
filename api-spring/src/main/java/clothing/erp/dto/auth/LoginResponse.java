package com.clothing.erp.dto.auth;

import com.clothing.erp.dto.shop.ShopBrief;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginResponse {

    private String token;
    private Long userId;
    private String phone;
    private String nickname;
    private List<ShopBrief> shops;
}
