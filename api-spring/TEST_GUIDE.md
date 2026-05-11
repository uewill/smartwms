# SmartWMS 单元测试套件

## 测试概述

本测试套件为 SmartWMS 智能仓库管理系统提供完整的单元测试覆盖，包括：

- **Service 层测试**：业务逻辑测试
- **Controller 层测试**：API 端点测试

## 测试文件清单

### Service 层测试

1. **AuthServiceTest.java** - 认证服务测试
   - 用户登录测试（密码登录、验证码登录）
   - 用户注册测试
   - 微信绑定测试
   - 密码修改测试
   - 用户信息获取测试

2. **ProductServiceTest.java** - 商品服务测试
   - 商品查询测试（关键字查询、分类查询）
   - 商品创建测试（重复编码检测）
   - 商品更新测试
   - 商品删除测试
   - 低库存商品查询测试

3. **WarehouseServiceTest.java** - 仓库服务测试
   - 仓库查询测试
   - 仓库创建测试
   - 仓库更新测试
   - 仓库删除测试
   - 仓库统计信息测试

4. **InboundServiceTest.java** - 入库服务测试
   - 入库单查询测试
   - 入库单创建测试（库存更新验证）
   - 入库单状态更新测试
   - 入库单删除测试

5. **OutboundServiceTest.java** - 出库服务测试
   - 出库单查询测试
   - 出库单创建测试（库存不足检测）
   - 出库单状态更新测试
   - 出库单删除测试

### Controller 层测试

6. **ProductControllerTest.java** - 商品控制器测试
   - GET /api/products - 商品列表查询
   - GET /api/products/{id} - 商品详情查询
   - POST /api/products - 创建商品
   - PUT /api/products/{id} - 更新商品
   - DELETE /api/products/{id} - 删除商品
   - GET /api/products/low-stock - 低库存商品查询

7. **WarehouseControllerTest.java** - 仓库控制器测试
   - GET /api/warehouses - 仓库列表查询
   - GET /api/warehouses/{id} - 仓库详情查询
   - POST /api/warehouses - 创建仓库
   - PUT /api/warehouses/{id} - 更新仓库
   - DELETE /api/warehouses/{id} - 删除仓库
   - GET /api/warehouses/stats - 仓库统计信息

## 测试技术栈

- **JUnit 5** - 测试框架
- **Mockito** - 模拟对象框架
- **Spring Boot Test** - Spring Boot 测试支持
- **MockMvc** - HTTP 模拟测试
- **H2 Database** - 内存数据库（测试环境）

## 运行测试

### 使用 Maven 运行测试

```bash
cd /workspace/smartwms/api-spring

# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=AuthServiceTest

# 生成测试报告
mvn test jacoco:report
```

### 使用 Gradle 运行测试

```bash
cd /workspace/smartwms/api-spring

# 运行所有测试
gradle test

# 运行特定测试类
gradle test --tests "com.smartwms.service.AuthServiceTest"

# 生成测试报告
gradle test
```

## 测试配置

### 测试环境配置

测试使用 H2 内存数据库，配置文件位于：
- `src/test/resources/application-test.yml`

配置内容：
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1;MODE=MySQL
    driver-class-name: org.h2.Driver
    username: sa
    password:
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: false
    database-platform: org.hibernate.dialect.H2Dialect

server:
  port: 0

jwt:
  secret: test-secret-key-for-unit-testing-only-not-for-production
  expiration: 86400000
```

## 测试覆盖范围

### 核心业务逻辑

| 模块 | 功能点 | 测试状态 |
|------|--------|----------|
| 认证 | 用户注册 | ✅ 已实现 |
| 认证 | 密码登录 | ✅ 已实现 |
| 认证 | 验证码登录 | ✅ 已实现 |
| 认证 | 微信登录 | ✅ 已实现 |
| 认证 | 密码修改 | ✅ 已实现 |
| 商品 | CRUD 操作 | ✅ 已实现 |
| 商品 | 关键字搜索 | ✅ 已实现 |
| 商品 | 低库存预警 | ✅ 已实现 |
| 仓库 | CRUD 操作 | ✅ 已实现 |
| 仓库 | 统计信息 | ✅ 已实现 |
| 入库 | 入库流程 | ✅ 已实现 |
| 入库 | 库存更新 | ✅ 已实现 |
| 出库 | 出库流程 | ✅ 已实现 |
| 出库 | 库存检查 | ✅ 已实现 |

### 错误处理

| 场景 | 测试状态 |
|------|----------|
| 用户不存在 | ✅ 已实现 |
| 商品不存在 | ✅ 已实现 |
| 仓库不存在 | ✅ 已实现 |
| 验证码错误 | ✅ 已实现 |
| 验证码过期 | ✅ 已实现 |
| 库存不足 | ✅ 已实现 |
| 重复编码 | ✅ 已实现 |

## Maven 仓库配置

由于网络限制，建议配置国内镜像：

### 阿里云镜像

在 `~/.m2/settings.xml` 中配置：

```xml
<mirrors>
  <mirror>
    <id>aliyun</id>
    <name>Aliyun Maven</name>
    <url>https://maven.aliyun.com/repository/public</url>
    <mirrorOf>central</mirrorOf>
  </mirror>
</mirrors>
```

### 清华镜像

```xml
<mirrors>
  <mirror>
    <id>tsinghua</id>
    <name>Tsinghua Maven</name>
    <url>https://maven.tuna.tsinghua.edu.cn/repository/maven-central/</url>
    <mirrorOf>central</mirrorOf>
  </mirror>
</mirrors>
```

## 测试报告

测试完成后，报告生成在：

- Maven: `target/site/jacoco/index.html`
- Gradle: `build/reports/tests/test/index.html`

## 添加新测试

### 添加 Service 测试

```java
package com.smartwms.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NewServiceTest {

    @Mock
    private NewRepository newRepository;

    @InjectMocks
    private NewService newService;

    @BeforeEach
    void setUp() {
        // 初始化测试数据
    }

    @Test
    void testNewMethod_Success() {
        // 测试成功场景
    }

    @Test
    void testNewMethod_Exception() {
        // 测试异常场景
    }
}
```

### 添加 Controller 测试

```java
package com.smartwms.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(NewController.class)
class NewControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private NewService newService;

    @Test
    void testEndpoint() throws Exception {
        mockMvc.perform(get("/api/new"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(0));
    }
}
```
