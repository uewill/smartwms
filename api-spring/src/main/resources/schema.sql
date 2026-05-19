CREATE DATABASE IF NOT EXISTS clothing_erp
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE clothing_erp;

-- ============================================================
-- 用户与租户
-- ============================================================

CREATE TABLE IF NOT EXISTS sys_user (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone        VARCHAR(20)  NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    nickname     VARCHAR(50),
    avatar       VARCHAR(500),
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS shop (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    owner_id     BIGINT       NOT NULL,
    invite_code  VARCHAR(50)  NOT NULL UNIQUE,
    address      VARCHAR(500),
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_shop_owner_id (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS shop_member (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id      BIGINT       NOT NULL,
    user_id      BIGINT       NOT NULL,
    role         VARCHAR(20)  NOT NULL COMMENT 'OWNER/ADMIN/STAFF',
    permissions  TEXT         COMMENT 'JSON权限列表如["sale","inventory"]',
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop_member_shop_id (shop_id),
    INDEX idx_shop_member_user_id (user_id),
    UNIQUE INDEX uk_shop_user (shop_id, user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS shop_invite (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id      BIGINT       NOT NULL,
    invite_code  VARCHAR(50)  NOT NULL UNIQUE,
    expire_at    DATETIME     NOT NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_shop_invite_shop_id (shop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 商品
-- ============================================================

CREATE TABLE IF NOT EXISTS product (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id               BIGINT       NOT NULL,
    style_no              VARCHAR(100) COMMENT '款号',
    name                  VARCHAR(200) NOT NULL,
    brand                 VARCHAR(100),
    season                VARCHAR(10)  COMMENT '春/夏/秋/冬',
    image_url             VARCHAR(500),
    thumb_url             VARCHAR(500),
    one_hand_code_preset  TEXT         COMMENT 'JSON一手码预设',
    created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_shop_id (shop_id),
    INDEX idx_product_style_no (style_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_color (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id   BIGINT       NOT NULL,
    color_name   VARCHAR(50)  NOT NULL,
    color_code   VARCHAR(20),
    INDEX idx_product_color_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_size (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id   BIGINT       NOT NULL,
    size_name    VARCHAR(20)  NOT NULL,
    sort_order   INT          NOT NULL DEFAULT 0,
    INDEX idx_product_size_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_sku (
    id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id         BIGINT        NOT NULL,
    color_id           BIGINT        NOT NULL,
    size_id            BIGINT        NOT NULL,
    barcode            VARCHAR(50),
    retail_price       DECIMAL(12,2) COMMENT '零售价',
    wholesale_price    DECIMAL(12,2) COMMENT '批发价',
    purchase_price     DECIMAL(12,2) COMMENT '拿货价',
    stock_qty          INT           NOT NULL DEFAULT 0 COMMENT '库存',
    stock_warning_qty  INT           NOT NULL DEFAULT 0 COMMENT '库存预警下限',
    created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_sku_product_id (product_id),
    INDEX idx_product_sku_barcode (barcode)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 客户
-- ============================================================

CREATE TABLE IF NOT EXISTS customer (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id           BIGINT        NOT NULL,
    name              VARCHAR(100)  NOT NULL,
    phone             VARCHAR(20),
    remark            VARCHAR(500),
    total_debt        DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '累计欠款',
    last_purchase_at  DATETIME,
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_shop_id (shop_id),
    INDEX idx_customer_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_price (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id    BIGINT        NOT NULL,
    sku_id         BIGINT        NOT NULL,
    special_price  DECIMAL(12,2) NOT NULL COMMENT '客户专属价',
    INDEX idx_customer_price_customer_id (customer_id),
    INDEX idx_customer_price_sku_id (sku_id),
    UNIQUE INDEX uk_customer_sku (customer_id, sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 销售
-- ============================================================

CREATE TABLE IF NOT EXISTS sale_order (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id          BIGINT        NOT NULL,
    order_no         VARCHAR(50)   NOT NULL,
    customer_id      BIGINT        COMMENT '可空',
    user_id          BIGINT        NOT NULL COMMENT '开单人',
    total_amount     DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_amount  DECIMAL(12,2) NOT NULL DEFAULT 0,
    actual_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_method   VARCHAR(20)   COMMENT 'CASH/WECHAT/ALIPAY/CREDIT',
    remark           VARCHAR(500),
    order_type       VARCHAR(10)   NOT NULL COMMENT 'SALE/RETURN',
    ref_order_id     BIGINT        COMMENT '退货关联原单',
    status           VARCHAR(20)   NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/COMPLETED/CANCELLED',
    created_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sale_order_shop_id (shop_id),
    INDEX idx_sale_order_order_no (order_no),
    INDEX idx_sale_order_customer_id (customer_id),
    INDEX idx_sale_order_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sale_order_item (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT        NOT NULL,
    sku_id          BIGINT        NOT NULL,
    product_id      BIGINT        NOT NULL,
    color_name      VARCHAR(50),
    size_name       VARCHAR(20),
    style_no        VARCHAR(100),
    quantity        INT           NOT NULL DEFAULT 0,
    unit_price      DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_price     DECIMAL(12,2) NOT NULL DEFAULT 0,
    purchase_price  DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT '拿货成本',
    INDEX idx_sale_order_item_order_id (order_id),
    INDEX idx_sale_order_item_sku_id (sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 采购
-- ============================================================

CREATE TABLE IF NOT EXISTS purchase_order (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id        BIGINT        NOT NULL,
    order_no       VARCHAR(50)   NOT NULL,
    supplier_name  VARCHAR(100),
    total_amount   DECIMAL(12,2) NOT NULL DEFAULT 0,
    remark         VARCHAR(500),
    order_type     VARCHAR(10)   NOT NULL COMMENT 'PURCHASE/RETURN',
    status         VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_purchase_order_shop_id (shop_id),
    INDEX idx_purchase_order_order_no (order_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_order_item (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id     BIGINT        NOT NULL,
    sku_id       BIGINT        NOT NULL,
    product_id   BIGINT        NOT NULL,
    color_name   VARCHAR(50),
    size_name    VARCHAR(20),
    style_no     VARCHAR(100),
    quantity     INT           NOT NULL DEFAULT 0,
    unit_price   DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_price  DECIMAL(12,2) NOT NULL DEFAULT 0,
    INDEX idx_purchase_order_item_order_id (order_id),
    INDEX idx_purchase_order_item_sku_id (sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 库存
-- ============================================================

CREATE TABLE IF NOT EXISTS stock_movement (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id        BIGINT       NOT NULL,
    sku_id         BIGINT       NOT NULL,
    movement_type  VARCHAR(5)   NOT NULL COMMENT 'IN/OUT',
    quantity       INT          NOT NULL DEFAULT 0,
    ref_type       VARCHAR(20)  COMMENT 'SALE/PURCHASE/INVENTORY/TRANSFER',
    ref_id         BIGINT,
    remark         VARCHAR(500),
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_stock_movement_shop_id (shop_id),
    INDEX idx_stock_movement_sku_id (sku_id),
    INDEX idx_stock_movement_ref (ref_type, ref_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inventory_check (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id      BIGINT       NOT NULL,
    check_no     VARCHAR(50)  NOT NULL,
    scope_type   VARCHAR(20)  NOT NULL COMMENT 'ALL/BRAND/SEASON/CATEGORY',
    scope_value  VARCHAR(100),
    status       VARCHAR(20)  NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/COMPLETED',
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inventory_check_shop_id (shop_id),
    INDEX idx_inventory_check_check_no (check_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inventory_check_item (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    check_id     BIGINT  NOT NULL,
    sku_id       BIGINT  NOT NULL,
    system_qty   INT     NOT NULL DEFAULT 0,
    actual_qty   INT     NOT NULL DEFAULT 0,
    diff_qty     INT     NOT NULL DEFAULT 0,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_inventory_check_item_check_id (check_id),
    INDEX idx_inventory_check_item_sku_id (sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS stock_transfer (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id_from  BIGINT      NOT NULL,
    shop_id_to    BIGINT      NOT NULL,
    transfer_no   VARCHAR(50) NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/CONFIRMED',
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_stock_transfer_from (shop_id_from),
    INDEX idx_stock_transfer_to (shop_id_to),
    INDEX idx_stock_transfer_no (transfer_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS stock_transfer_item (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    transfer_id  BIGINT NOT NULL,
    sku_id       BIGINT NOT NULL,
    quantity     INT    NOT NULL DEFAULT 0,
    INDEX idx_stock_transfer_item_transfer_id (transfer_id),
    INDEX idx_stock_transfer_item_sku_id (sku_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 还款
-- ============================================================

CREATE TABLE IF NOT EXISTS payment_record (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id      BIGINT        NOT NULL,
    customer_id  BIGINT        NOT NULL,
    amount       DECIMAL(12,2) NOT NULL,
    remark       VARCHAR(500),
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_record_shop_id (shop_id),
    INDEX idx_payment_record_customer_id (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS payment_allocation (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id        BIGINT        NOT NULL,
    order_id          BIGINT        NOT NULL,
    allocated_amount  DECIMAL(12,2) NOT NULL,
    INDEX idx_payment_allocation_payment_id (payment_id),
    INDEX idx_payment_allocation_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 订阅
-- ============================================================

CREATE TABLE IF NOT EXISTS subscription (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    shop_id     BIGINT      NOT NULL,
    plan_type   VARCHAR(20) NOT NULL COMMENT 'BASIC/PREMIUM',
    start_date  DATE        NOT NULL,
    end_date    DATE        NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/EXPIRED/CANCELLED',
    max_shops   INT         NOT NULL DEFAULT 1,
    created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_subscription_shop_id (shop_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
