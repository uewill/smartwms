package com.clothing.erp.dto.shop;

import lombok.Data;

@Data
public class UpdateMemberRequest {

    private String role;
    private String permissions;
}
