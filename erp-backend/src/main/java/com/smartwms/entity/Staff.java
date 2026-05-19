package com.smartwms.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "staffs")
public class Staff {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long tenantId;

    private Long userId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String phone;

    private String email;

    @Column(nullable = false)
    private Integer level = 3;

    private String permissions;
    private String wechatOpenId;
    private String remark;

    @Column(nullable = false)
    private String status = "active";

    private LocalDateTime lastLoginAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public boolean isSuperAdmin() {
        return level == 1;
    }

    public boolean isAdmin() {
        return level <= 2;
    }

    public boolean canManageProduct() {
        return level <= 2;
    }

    public boolean canManageWarehouse() {
        return level <= 2;
    }

    public boolean canInbound() {
        return level <= 3;
    }

    public boolean canOutbound() {
        return level <= 3;
    }

    public boolean canViewReport() {
        return true;
    }

    public boolean canManageStaff() {
        return level == 1;
    }
}
