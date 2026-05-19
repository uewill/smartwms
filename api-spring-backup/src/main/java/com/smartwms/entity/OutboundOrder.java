package com.smartwms.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Entity
@Table(name = "outbound_orders")
public class OutboundOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String orderNo;

    @Column(nullable = false)
    private Long tenantId;

    @Column(nullable = false)
    private Long warehouseId;

    private String warehouseName;
    private String customer;
    private Integer totalQuantity = 0;
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(nullable = false)
    private String status = "pending";

    private String remark;
    private Long operatorId;
    private String operatorName;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Transient
    private List<OutboundItem> items;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (orderNo == null) {
            orderNo = "OUT" + System.currentTimeMillis();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
