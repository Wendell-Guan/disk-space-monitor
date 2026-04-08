#!/bin/bash

echo "=== 安装磁盘空间监控 GUI 应用 ==="
echo ""

# 检查 Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ 未找到 Python 3"
    echo "请先安装 Python 3: brew install python3"
    exit 1
fi

echo "✅ 找到 Python 3: $(python3 --version)"
echo ""

# 安装 rumps 库
echo "📦 安装依赖库 rumps..."
pip3 install rumps pyobjc --quiet

if [ $? -eq 0 ]; then
    echo "✅ 依赖安装成功"
else
    echo "❌ 依赖安装失败"
    exit 1
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "启动状态栏应用："
echo "  python3 ~/disk-space-monitor/statusbar_app.py"
echo ""
echo "或者设置为开机自启："
echo "  1. 打开「系统设置」→「通用」→「登录项」"
echo "  2. 添加脚本: ~/disk-space-monitor/statusbar_app.py"
