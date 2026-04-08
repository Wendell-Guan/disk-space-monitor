#!/bin/bash
# 启动中文版状态栏应用

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🚀 启动磁盘空间监控（中文版）..."

# 检查 rumps 是否安装
if ! python3 -c "import rumps" 2>/dev/null; then
    echo "❌ 未安装 rumps 库"
    echo "正在安装..."
    pip3 install rumps
fi

# 启动中文版应用
cd "$SCRIPT_DIR"
python3 statusbar_app_zh.py &

echo "✅ 中文版已启动！查看菜单栏右上角"
