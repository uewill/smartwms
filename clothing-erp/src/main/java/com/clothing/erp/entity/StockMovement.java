package com.clothing.erp.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "stock_movement")
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sku_id", nullable = false)
    private ProductSku sku;

    @Column(name = "movement_type", nullable = false, length = 5)
    @Enumerated(EnumType.STRING)
    private MovementType movementType;

    @Column(nullable = false)
    private Integer quantity = 0;

    @Column(name = "ref_type", length = 20)
    @Enumerated(EnumType.STRING)
    private RefType refType;

    @Column(name = "ref_id")
    private Long refId;

    @Column(length = 500)
    private String remark;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    public enum MovementType {
        IN, OUT
    }

    public enum RefType {
        SALE, PURCHASE, INVENTORY, TRANSFER
    }
}
