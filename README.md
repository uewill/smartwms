# SmartWMS - 智能仓库管理系统

一个功能完善的仓库管理系统，支持多租户架构，包含 Web 管理端、移动端 App 和后端 API。

## 系统架构

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Flutter    │     │   Vue3      │     │  Spring     │
│   App       │     │  Web Admin  │     │   Boot API  │
│  (Mobile)   │     │  (Desktop)  │     │  (Backend)   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌──────┴──────┐
                    │    MySQL    │
                    │ (Multi-tenant)
                    └─────────────┘
```

## 技术栈

### 移动端 (Flutter)
- Flutter 3.x
- Provider 状态管理
- Dio 网络请求
- Material Design 3

### Web 管理端 (Vue3)
- Vue 3 + Composition API
- Arco Design Web Vue
- Pinia 状态管理
- Axios HTTP 客户端

### 后端 (Spring Boot)
- Spring Boot 3.2
- Spring Data JPA
- MySQL 8.0
- JWT 认证
- Redis (可选)

## 功能模块

### 核心功能
- [x] 多租户数据隔离
- [x] 用户认证 (手机号+验证码/密码/微信)
- [x] 商品管理 (CRUD + 库存预警)
- [x] 入库管理 (创建 + 审核 + 状态流转)
- [x] 出库管理 (创建 + 审核 + 状态流转)
- [x] 仓库管理 (多仓库支持)
- [x] 员工管理 (权限分级)
- [x] 数据报表 (库存/成本/趋势)

### 权限分级
| 角色 | 商品 | 仓库 | 入库 | 出库 | 报表 | 员工 |
|------|------|------|------|------|------|------|
| 超级管理员 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 管理员 | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| 操作员 | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| 查看者 | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |

## 快速开始

### 环境要求
- Node.js 18+
- Java 21
- MySQL 8.0
- Flutter 3.x (移动端构建)

### 1. 数据库初始化

```bash
mysql -uroot -p < sql/init.sql
```

### 2. 后端 API

```bash
cd api-spring
mvn clean package -DskipTests
java -jar target/smartwms-api-1.0.0.jar
```

API 地址: http://localhost:8080

### 3. Web 管理端

```bash
cd web-admin
npm install
npm run dev
```

Web 地址: http://localhost:5173

### 4. 移动端 (可选)

```bash
cd app
flutter pub get
flutter run
```

## API 接口

### 认证接口
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/auth/send-code | 发送验证码 |
| POST | /api/auth/login-by-code | 验证码登录 |
| POST | /api/auth/login-by-pwd | 密码登录 |
| POST | /api/auth/register | 注册 |
| GET | /api/auth/user-info | 获取用户信息 |

### 业务接口
| 模块 | 路径前缀 |
|------|----------|
| 商品 | /api/products |
| 仓库 | /api/warehouses |
| 入库 | /api/inbound |
| 出库 | /api/outbound |
| 报表 | /api/reports |
| 员工 | /api/staffs |

## 配置说明

### 后端配置 (api-spring/src/main/resources/application.properties)

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/smartwms
spring.datasource.username=root
spring.datasource.password=your_password
```

### 前端配置 (app/lib/config/app_config.dart)

```dart
static const String baseUrl = 'http://your-server:8080';
```

## 项目结构

```
smartwms/
├── app/                    # Flutter 移动端
│   ├── lib/
│   │   ├── config/        # 配置文件
│   │   ├── models/       # 数据模型
│   │   ├── pages/        # 页面组件
│   │   ├── providers/    # 状态管理
│   │   └── services/     # API 服务
│   └── pubspec.yaml
│
├── web-admin/              # Vue3 Web 管理端
│   ├── src/
│   │   ├── api/          # API 调用
│   │   ├── store/        # 状态管理
│   │   ├── utils/        # 工具函数
│   │   └── views/        # 页面组件
│   └── package.json
│
├── api-spring/            # Spring Boot 后端
│   └── src/main/java/com/smartwms/
│       ├── controller/   # 控制器
│       ├── entity/       # 实体类
│       ├── repository/   # 数据访问
│       ├── service/      # 业务逻辑
│       └── middleware/   # 中间件
│
└── sql/                   # 数据库脚本
    └── init.sql
```

## 测试账号

| 角色 | 手机号 | 密码 |
|------|--------|------|
| 超级管理员 | 13800138000 | admin123 |

## License

MIT License
