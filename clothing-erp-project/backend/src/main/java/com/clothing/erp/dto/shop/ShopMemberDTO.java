package com.clothing.erp.dto.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShopMemberDTO {

    private Long id;
    private Long userId;
    private String nickname;
    private String phone;
    private String role;
    private String permissions;
}
