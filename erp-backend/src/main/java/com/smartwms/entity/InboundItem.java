package com.smartwms.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Entity
@Table(name = "inbound_items")
public class InboundItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long orderId;

    @Column(nullable = false)
    private Long productId;

    private String productName;
    private String productCode;
    private Integer quantity = 0;
    private BigDecimal price = BigDecimal.ZERO;
    private BigDecimal amount = BigDecimal.ZERO;
}
