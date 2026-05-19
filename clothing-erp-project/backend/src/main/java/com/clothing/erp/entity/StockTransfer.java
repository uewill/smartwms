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
@Table(name = "stock_transfer")
public class StockTransfer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id_from", nullable = false)
    private Shop shopFrom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id_to", nullable = false)
    private Shop shopTo;

    @Column(name = "transfer_no", nullable = false, length = 50)
    private String transferNo;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private TransferStatus status = TransferStatus.PENDING;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "transfer", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StockTransferItem> items;

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

    public enum TransferStatus {
        PENDING, CONFIRMED
    }
}
