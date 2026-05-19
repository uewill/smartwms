package com.clothing.erp.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "inventory_check")
public class InventoryCheck {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @Column(name = "check_no", nullable = false, length = 50)
    private String checkNo;

    @Column(name = "scope_type", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private ScopeType scopeType;

    @Column(name = "scope_value", length = 100)
    private String scopeValue;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private InventoryCheckStatus status = InventoryCheckStatus.DRAFT;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "check", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<InventoryCheckItem> items;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public enum ScopeType {
        ALL, BRAND, SEASON, CATEGORY
    }

    public enum InventoryCheckStatus {
        DRAFT, COMPLETED
    }
}
