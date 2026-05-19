# 服装小微 ERP APP - Clothing ERP

专注小微服装店的开单管货对账极简APP，比秦丝更轻，比通用进销存更懂服装

## 项目概述

本项目是一个完整的服装 ERP 系统，包含：
- **后端**：Spring Boot 3.2 + MySQL + JPA + Spring Security + JWT
- **前端**：Flutter 3.x + Provider + Dio

## 技术栈

### 后端
- Spring Boot 3.2
- Spring Security + JWT
- Spring Data JPA
- MySQL / H2 数据库
- Apache POI（Excel导出）
- Lombok

### 前端
- Flutter 3.x
- Provider 状态管理
- Dio 网络请求
- Mobile Scanner（扫码功能）
- Intl（国际化）

## 项目结构

```
clothing-erp-project/
├── backend/
│   ├── pom.xml
│   └── src/
│       ├── main/
│       │   ├── java/com/clothing/erp/
│       │   │   ├── common/
│       │   │   ├── config/
│       │   │   ├── controller/
│       │   │   ├── dto/
│       │   │   ├── entity/
│       │   │   ├── repository/
│       │   │   ├── service/
│       │   │   ├── util/
│       │   │   └── ErpApplication.java
│       │   └── resources/
│       │       ├── application.yml
│       │       └── schema.sql
│       └── test/
└── frontend/
    ├── pubspec.yaml
    └── lib/
        ├── config/
        ├── models/
        ├── network/
        ├── pages/
        ├── providers/
        ├── routes/
        ├── widgets/
        ├── app.dart
        └── main.dart
```

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.9+
- Flutter 3.x
- MySQL 8.0+（或使用 H2 内存数据库）

### 后端运行

#### 方式一：使用 H2 内存数据库（快速启动）

1. 进入后端目录：
```bash
cd clothing-erp-project/backend
```

2. 确认 `application.yml` 中的配置：
```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:h2:mem:clothing_erp;DB_CLOSE_DELAY=-1;MODE=MySQL
    username: sa
    password: 
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true
      path: /h2-console
  jpa:
    hibernate:
      ddl-auto: update
```

3. 运行：
```bash
mvn spring-boot:run
```

4. 访问：
- API 地址：http://localhost:8080
- H2 控制台：http://localhost:8080/h2-console

#### 方式二：使用 MySQL

1. 创建数据库：
```sql
CREATE DATABASE clothing_erp DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 修改 `application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/clothing_erp?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=utf8mb4
    username: root
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      dialect: org.hibernate.dialect.MySQLDialect
```

### 前端运行

1. 进入前端目录：
```bash
cd clothing-erp-project/frontend
```

2. 安装依赖：
```bash
flutter pub get
```

3. 修改 API 配置：
编辑 `lib/config/api_config.dart`，修改 baseUrl

4. 运行：
```bash
flutter run
```

## 功能模块

### 1. 用户认证与多店铺管理
- 用户注册/登录
- 店铺创建
- 店铺切换
- 店员管理

### 2. 商品管理
- 商品创建/编辑/删除
- 颜色尺码矩阵
- 一手码预设
- 图片上传
- 本地缓存加速

### 3. 销售开单
- 摄像头扫码开单
- 手工选款开单
- 销售退货
- 整单折扣/抹零
- 多支付方式（现金/微信/支付宝/赊账）
- 蓝牙打印小票（高级版）

### 4. 客户管理
- 客户档案
- 欠款管理
- 收款核销
- 对账单（高级版）

### 5. 采购入库
- 采购订单
- 采购退货
- 供应商管理

### 6. 库存管理
- 库存查询
- 库存盘点
- 库存预警
- 店间调拨

### 7. 报表分析
- 今日概览（销售额/毛利/订单数）
- 热卖排行
- 库存积压预警
- 利润分析
- Excel 导出

### 8. 版本与权限
- 基础版（免费）
- 高级版（付费，功能开关控制）

## API 文档

| 模块 | 路径 | 说明 |
|-----|-----|-----|
| 用户认证 | /api/auth | 注册/登录 |
| 店铺管理 | /api/shops | 店铺/店员 |
| 商品管理 | /api/shops/{id}/products | 商品/SKU |
| 销售开单 | /api/shops/{id}/sale-orders | 开单/退货 |
| 客户管理 | /api/shops/{id}/customers | 客户/欠款/对账单 |
| 采购管理 | /api/shops/{id}/purchase-orders | 采购/退货 |
| 库存管理 | /api/shops/{id}/stock | 库存/盘点/调拨 |
| 报表分析 | /api/shops/{id}/reports | 概览/排行/导出 |
| 订阅管理 | /api/shops/{id}/subscription | 订阅/版本对比 |

## 核心特性

### 多租户隔离
- 每个店铺数据完全独立
- 用户可以创建/加入多个店铺

### 赊账管理
- 支持销售开单选择赊账
- 自动记录客户欠款
- 按余额自动核销

### 商品管理
- 颜色尺码矩阵自动展开
- 一手码快速预设
- 图片懒加载和压缩

### 扫码开单
- 摄像头连续扫码
- 本地缓存商品信息，确保毫秒响应

### 报表功能
- 完整的进销存报表
- 支持 Excel 导出
- 高级版功能开关控制

## 部署说明

### 后端部署
```bash
mvn clean package
java -jar target/clothing-erp-1.0.0.jar
```

### 前端部署
- Android：`flutter build apk`
- iOS：`flutter build ios`
- Web：`flutter build web`

## 版本说明

| 功能 | 基础版 | 高级版 |
|-----|-------|-------|
| 商品管理 | ✓ | ✓ |
| 销售开单 | ✓ | ✓ |
| 客户欠款 | ✓ | ✓ |
| 采购入库 | ✓ | ✓ |
| 库存管理 | ✓ | ✓ |
| 今日概览 | ✓ | ✓ |
| 蓝牙打印 | ✗ | ✓ |
| 客户对账单 | ✗ | ✓ |
| 高级报表 | ✗ | ✓ |
| Excel 导出 | ✗ | ✓ |
| 库存预警推送 | ✗ | ✓ |
| 多店管理（>2） | ✗ | ✓ |
| 多店聚合报表 | ✗ | ✓ |

## 开发说明

### 本地开发
1. 后端：IntelliJ IDEA / Eclipse
2. 前端：VS Code / Android Studio

### 测试
- 后端单元测试
- 前端 Widget 测试

## License

Copyright © 2025 Clothing ERP
