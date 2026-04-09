#!/bin/bash

# 重启磁盘空间监控应用

echo "🔄 正在重启磁盘空间监控..."

# 停止现有进程
echo "⏹️  停止现有进程..."
pkill -f "statusbar_app" 2>/dev/null
sleep 1

# 启动中文版
echo "🚀 启动中文版..."
cd ~/disk-space-monitor
python3 statusbar_app_zh.py &

sleep 1
echo "✅ 重启完成！查看菜单栏右上角 💾 图标"
