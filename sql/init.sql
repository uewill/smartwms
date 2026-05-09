-- SmartWMS 数据库初始化脚本
-- 支持 MySQL 5.7+

CREATE DATABASE IF NOT EXISTS smartwms DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartwms;

-- 租户表
CREATE TABLE IF NOT EXISTS tenants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '租户名称',
    phone VARCHAR(20) NOT NULL COMMENT '联系电话',
    logo VARCHAR(255) COMMENT 'Logo URL',
    address VARCHAR(255) COMMENT '地址',
    status INT DEFAULT 1 COMMENT '状态 1-正常 0-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户表';

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号',
    nickname VARCHAR(50) NOT NULL COMMENT '昵称',
    password VARCHAR(255) COMMENT '密码（SHA256）',
    avatar VARCHAR(255) COMMENT '头像URL',
    wechat_open_id VARCHAR(100) COMMENT '微信OpenID',
    status INT DEFAULT 1 COMMENT '状态 1-正常 0-停用',
    last_login_at DATETIME COMMENT '最后登录时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_phone (phone),
    INDEX idx_wechat_open_id (wechat_open_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 职员表（基于级别的权限控制，无角色）
CREATE TABLE IF NOT EXISTS staffs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    user_id BIGINT COMMENT '关联用户ID',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    level INT DEFAULT 3 COMMENT '级别 1-超级管理员 2-管理员 3-操作员 4-查看者',
    permissions VARCHAR(500) COMMENT '权限列表，逗号分隔，*表示全部权限',
    wechat_open_id VARCHAR(100) COMMENT '微信OpenID',
    remark VARCHAR(255) COMMENT '备注',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态 active-正常 inactive-停用',
    last_login_at DATETIME COMMENT '最后登录时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_user_id (user_id),
    INDEX idx_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职员表';

-- 短信验证码表
CREATE TABLE IF NOT EXISTS sms_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(20) NOT NULL COMMENT '手机号',
    code VARCHAR(10) NOT NULL COMMENT '验证码',
    type VARCHAR(20) NOT NULL COMMENT '类型 login-登录 register-注册 bind-绑定',
    expire_time DATETIME NOT NULL COMMENT '过期时间',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_type (phone, type),
    INDEX idx_expire_time (expire_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信验证码表';

-- 商品表
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '商品编码',
    name VARCHAR(100) NOT NULL COMMENT '商品名称',
    spec VARCHAR(100) COMMENT '规格型号',
    unit VARCHAR(20) DEFAULT '个' COMMENT '单位',
    price DECIMAL(12,2) DEFAULT 0 COMMENT '售价',
    cost_price DECIMAL(12,2) DEFAULT 0 COMMENT '成本价',
    warning_stock INT DEFAULT 0 COMMENT '库存预警值',
    stock_quantity INT DEFAULT 0 COMMENT '库存数量',
    category VARCHAR(50) COMMENT '商品分类',
    remark VARCHAR(255) COMMENT '备注',
    image VARCHAR(255) COMMENT '商品图片URL',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态 active-正常 inactive-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_code (code),
    INDEX idx_category (category),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 仓库表
CREATE TABLE IF NOT EXISTS warehouses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    name VARCHAR(100) NOT NULL COMMENT '仓库名称',
    address VARCHAR(255) COMMENT '仓库地址',
    contact VARCHAR(50) COMMENT '联系人',
    phone VARCHAR(20) COMMENT '联系电话',
    is_default INT DEFAULT 0 COMMENT '是否默认仓库 1-是 0-否',
    product_count INT DEFAULT 0 COMMENT '商品种类数',
    total_stock INT DEFAULT 0 COMMENT '总库存量',
    status VARCHAR(20) DEFAULT 'active' COMMENT '状态 active-正常 inactive-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';

-- 入库单表
CREATE TABLE IF NOT EXISTS inbound_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    warehouse_name VARCHAR(100) COMMENT '仓库名称',
    supplier VARCHAR(100) COMMENT '供应商',
    total_quantity INT DEFAULT 0 COMMENT '总数量',
    total_amount DECIMAL(12,2) DEFAULT 0 COMMENT '总金额',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '状态 pending-待审核 approved-已审核 completed-已完成 cancelled-已取消',
    remark VARCHAR(255) COMMENT '备注',
    operator_id BIGINT COMMENT '操作员ID',
    operator_name VARCHAR(50) COMMENT '操作员姓名',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_order_no (order_no),
    INDEX idx_warehouse_id (warehouse_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单表';

-- 入库明细表
CREATE TABLE IF NOT EXISTS inbound_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(100) COMMENT '商品名称',
    product_code VARCHAR(50) COMMENT '商品编码',
    quantity INT DEFAULT 0 COMMENT '数量',
    price DECIMAL(12,2) DEFAULT 0 COMMENT '单价',
    amount DECIMAL(12,2) DEFAULT 0 COMMENT '金额',
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库明细表';

-- 出库单表
CREATE TABLE IF NOT EXISTS outbound_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    warehouse_name VARCHAR(100) COMMENT '仓库名称',
    customer VARCHAR(100) COMMENT '客户',
    total_quantity INT DEFAULT 0 COMMENT '总数量',
    total_amount DECIMAL(12,2) DEFAULT 0 COMMENT '总金额',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '状态 pending-待审核 approved-已审核 completed-已完成 cancelled-已取消',
    remark VARCHAR(255) COMMENT '备注',
    operator_id BIGINT COMMENT '操作员ID',
    operator_name VARCHAR(50) COMMENT '操作员姓名',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_order_no (order_no),
    INDEX idx_warehouse_id (warehouse_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单表';

-- 出库明细表
CREATE TABLE IF NOT EXISTS outbound_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL COMMENT '订单ID',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(100) COMMENT '商品名称',
    product_code VARCHAR(50) COMMENT '商品编码',
    quantity INT DEFAULT 0 COMMENT '数量',
    cost_price DECIMAL(12,2) DEFAULT 0 COMMENT '成本单价',
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库明细表';

-- 库存表
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    warehouse_name VARCHAR(100) COMMENT '仓库名称',
    product_id BIGINT NOT NULL COMMENT '商品ID',
    product_name VARCHAR(100) COMMENT '商品名称',
    product_code VARCHAR(50) COMMENT '商品编码',
    quantity INT DEFAULT 0 COMMENT '库存数量',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_warehouse_product (warehouse_id, product_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_warehouse_id (warehouse_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS operation_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT NOT NULL COMMENT '租户ID',
    staff_id BIGINT COMMENT '职员ID',
    staff_name VARCHAR(50) COMMENT '职员姓名',
    type VARCHAR(20) NOT NULL COMMENT '类型 login-登录 create-创建 update-更新 delete-删除',
    action VARCHAR(50) NOT NULL COMMENT '操作名称',
    detail VARCHAR(500) COMMENT '操作详情',
    ip VARCHAR(50) COMMENT 'IP地址',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_staff_id (staff_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 插入测试数据
INSERT INTO tenants (name, phone, address) VALUES 
('测试租户', '13800138000', '北京市朝阳区测试地址');

INSERT INTO users (tenant_id, phone, nickname, password) VALUES 
(1, '13800138000', '管理员', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'); -- 密码: 123456

INSERT INTO staffs (tenant_id, user_id, name, phone, level, permissions, status) VALUES 
(1, 1, '管理员', '13800138000', 1, '*', 'active');

INSERT INTO warehouses (tenant_id, name, address, contact, phone) VALUES 
(1, '主仓库', '北京市朝阳区仓库路1号', '张三', '13800138001'),
(1, '副仓库', '上海市浦东新区仓库路2号', '李四', '13800138002');

INSERT INTO products (tenant_id, code, name, spec, unit, price, cost_price, warning_stock, stock_quantity, category) VALUES 
(1, 'P001', 'iPhone 15', '128GB', '台', 6999.00, 5500.00, 10, 100, '手机'),
(1, 'P002', 'MacBook Pro', '14寸 M3', '台', 15999.00, 12000.00, 5, 50, '电脑'),
(1, 'P003', 'AirPods Pro', '二代', '个', 1899.00, 1400.00, 20, 200, '配件');
