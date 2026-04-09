#!/bin/bash

# 停止磁盘空间监控应用

echo "⏹️  停止磁盘空间监控..."
pkill -f "statusbar_app"

if [ $? -eq 0 ]; then
    echo "✅ 已停止"
else
    echo "ℹ️  应用未运行"
fi
