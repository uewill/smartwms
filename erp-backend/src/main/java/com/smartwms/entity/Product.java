package com.smartwms.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long tenantId;

    @Column(nullable = false, unique = true)
    private String code;

    @Column(nullable = false)
    private String name;

    private String spec;
    private String unit = "个";
    private BigDecimal price = BigDecimal.ZERO;
    private BigDecimal costPrice = BigDecimal.ZERO;
    private Integer warningStock = 0;
    private Integer stockQuantity = 0;
    private String category;
    private String remark;
    private String image;

    @Column(nullable = false)
    private String status = "active";

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
}
