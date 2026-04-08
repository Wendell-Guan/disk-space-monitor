#!/bin/bash

# 启动状态栏应用
echo "🚀 启动磁盘空间监控状态栏应用..."

# 检查依赖
if ! python3 -c "import rumps" 2>/dev/null; then
    echo "⚠️  未安装依赖，正在安装..."
    pip3 install rumps pyobjc --quiet
fi

# 启动应用
cd ~/disk-space-monitor
python3 statusbar_app.py &

echo "✅ 应用已启动！查看状态栏右上角 💾 图标"
