#!/bin/bash

echo "======================================"
echo "SmartWMS 单元测试统计"
echo "======================================"
echo ""

TEST_DIR="/workspace/smartwms/api-spring/src/test/java/com/smartwms"

echo "📊 测试文件统计"
echo "--------------------------------------"
echo "Service 层测试:"
find "$TEST_DIR/service" -name "*Test.java" 2>/dev/null | while read file; do
    count=$(grep -c "@Test" "$file" 2>/dev/null || echo "0")
    basename "$file" | sed 's/.java$//'
    echo "  - 测试方法数: $count"
done

echo ""
echo "Controller 层测试:"
find "$TEST_DIR/controller" -name "*Test.java" 2>/dev/null | while read file; do
    count=$(grep -c "@Test" "$file" 2>/dev/null || echo "0")
    basename "$file" | sed 's/.java$//'
    echo "  - 测试方法数: $count"
done

echo ""
echo "======================================"
echo "测试覆盖的模块"
echo "======================================"
echo ""
echo "✅ 认证模块 (AuthService)"
echo "   - 用户登录"
echo "   - 用户注册"
echo "   - 微信绑定"
echo "   - 密码修改"
echo ""
echo "✅ 商品模块 (ProductService)"
echo "   - 商品 CRUD"
echo "   - 关键字搜索"
echo "   - 低库存查询"
echo ""
echo "✅ 仓库模块 (WarehouseService)"
echo "   - 仓库 CRUD"
echo "   - 统计信息"
echo ""
echo "✅ 入库模块 (InboundService)"
echo "   - 入库单管理"
echo "   - 库存更新"
echo ""
echo "✅ 出库模块 (OutboundService)"
echo "   - 出库单管理"
echo "   - 库存检查"
echo ""
echo "======================================"
echo "总计"
echo "======================================"
total_tests=$(find "$TEST_DIR" -name "*Test.java" -exec grep -c "@Test" {} \; 2>/dev/null | awk '{sum+=$1} END {print sum}')
total_files=$(find "$TEST_DIR" -name "*Test.java" 2>/dev/null | wc -l)
echo "测试类数量: $total_files"
echo "测试方法总数: $total_tests"
echo ""
