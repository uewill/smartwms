#!/bin/bash

# SmartWMS Test Execution Script
# This script runs all unit tests and generates reports

set -e

PROJECT_DIR="/workspace/smartwms/api-spring"
cd "$PROJECT_DIR"

echo "=========================================="
echo "SmartWMS 单元测试执行脚本"
echo "=========================================="
echo ""

# Check for Maven
if command -v mvn &> /dev/null; then
    echo "✓ Maven 已安装"
    BUILD_TOOL="maven"
elif command -v gradle &> /dev/null; then
    echo "✓ Gradle 已安装"
    BUILD_TOOL="gradle"
else
    echo "✗ 未找到 Maven 或 Gradle"
    exit 1
fi

echo ""
echo "=========================================="
echo "测试前准备"
echo "=========================================="

# Clean previous test results
if [ -d "target" ]; then
    echo "清理旧的测试结果..."
    rm -rf target/surefire-reports
    rm -rf target/site
fi

echo ""
echo "=========================================="
echo "开始运行测试"
echo "=========================================="

if [ "$BUILD_TOOL" = "maven" ]; then
    echo "使用 Maven 运行测试..."
    mvn clean test -Dspring.profiles.active=test

    if [ $? -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "测试结果摘要"
        echo "=========================================="
        echo ""

        # Count test results
        PASSED=$(find target/surefire-reports -name "*.txt" -exec grep -c "Tests run:" {} \; 2>/dev/null | awk -F',' '{sum+=$1} END {print sum}' || echo "0")
        FAILED=$(find target/surefire-reports -name "*.txt" -exec grep "Failures:" {} \; 2>/dev/null | awk '{sum+=$2} END {print sum}' || echo "0")
        SKIPPED=$(find target/surefire-reports -name "*.txt" -exec grep "Skipped:" {} \; 2>/dev/null | awk '{sum+=$2} END {print sum}' || echo "0")

        echo "✓ 测试完成"
        echo ""
        echo "测试报告位置:"
        echo "  - HTML 报告: target/site/surefire-report.html"
        echo "  - 详细日志: target/surefire-reports/"
        echo ""

        # Generate coverage report if available
        if [ -f "pom.xml" ] && grep -q "jacoco" pom.xml; then
            echo "覆盖率报告:"
            echo "  - target/site/jacoco/index.html"
        fi
    else
        echo ""
        echo "=========================================="
        echo "测试失败 - 请检查日志"
        echo "=========================================="
        exit 1
    fi

elif [ "$BUILD_TOOL" = "gradle" ]; then
    echo "使用 Gradle 运行测试..."
    gradle clean test

    if [ $? -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "测试结果摘要"
        echo "=========================================="
        echo ""

        echo "✓ 测试完成"
        echo ""
        echo "测试报告位置:"
        echo "  - HTML 报告: build/reports/tests/test/index.html"
        echo "  - 详细日志: build/test-results/"
        echo ""

        # Generate coverage report if available
        if [ -f "build.gradle" ] && grep -q "jacoco" build.gradle; then
            echo "覆盖率报告:"
            echo "  - build/reports/jacoco/test/html/index.html"
        fi
    else
        echo ""
        echo "=========================================="
        echo "测试失败 - 请检查日志"
        echo "=========================================="
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "下一步操作"
echo "=========================================="
echo ""
echo "1. 查看 HTML 测试报告"
echo "2. 查看覆盖率报告"
echo "3. 修复失败的测试"
echo "4. 提交代码到 GitHub"
echo ""
