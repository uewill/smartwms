package com.smartwms.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import com.smartwms.entity.User;
import com.smartwms.entity.Staff;
import com.smartwms.entity.Tenant;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthResult {
    private String token;
    private UserDto user;
    private StaffDto staff;
    private TenantDto tenant;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class UserDto {
        private Long id;
        private Long tenantId;
        private String phone;
        private String nickname;
        private String avatar;
        private String wechatOpenId;
        private Integer status;

        public static UserDto fromEntity(User user) {
            if (user == null) return null;
            UserDto dto = new UserDto();
            dto.setId(user.getId());
            dto.setTenantId(user.getTenantId());
            dto.setPhone(user.getPhone());
            dto.setNickname(user.getNickname());
            dto.setAvatar(user.getAvatar());
            dto.setWechatOpenId(user.getWechatOpenId());
            dto.setStatus(user.getStatus());
            return dto;
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class StaffDto {
        private Long id;
        private Long tenantId;
        private Long userId;
        private String name;
        private String phone;
        private String email;
        private Integer level;
        private String permissions;
        private String status;
        private String remark;
        private String wechatOpenId;
        private String createdAt;
        private String lastLoginAt;

        public static StaffDto fromEntity(Staff staff) {
            if (staff == null) return null;
            StaffDto dto = new StaffDto();
            dto.setId(staff.getId());
            dto.setTenantId(staff.getTenantId());
            dto.setUserId(staff.getUserId());
            dto.setName(staff.getName());
            dto.setPhone(staff.getPhone());
            dto.setEmail(staff.getEmail());
            dto.setLevel(staff.getLevel());
            dto.setPermissions(staff.getPermissions());
            dto.setStatus(staff.getStatus());
            dto.setRemark(staff.getRemark());
            dto.setWechatOpenId(staff.getWechatOpenId());
            dto.setCreatedAt(staff.getCreatedAt() != null ? staff.getCreatedAt().toString() : null);
            dto.setLastLoginAt(staff.getLastLoginAt() != null ? staff.getLastLoginAt().toString() : null);
            return dto;
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class TenantDto {
        private Long id;
        private String name;
        private String phone;
        private String logo;
        private String address;

        public static TenantDto fromEntity(Tenant tenant) {
            if (tenant == null) return null;
            TenantDto dto = new TenantDto();
            dto.setId(tenant.getId());
            dto.setName(tenant.getName());
            dto.setPhone(tenant.getPhone());
            dto.setLogo(tenant.getLogo());
            dto.setAddress(tenant.getAddress());
            return dto;
        }
    }
}
