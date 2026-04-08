#!/bin/bash

# Real-time File Activity Monitor - 实时文件活动监控

echo "=== 实时文件写入监控 ==="
echo "监控正在写入文件的进程..."
echo "按 Ctrl+C 停止"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "提示：需要 sudo 权限以获取完整信息"
    echo "请运行: sudo $0"
    echo ""
fi

# 实时监控文件系统写入
sudo fs_usage -w -f filesys 2>/dev/null | grep -E "WrData|write" | while read line; do
    timestamp=$(date "+%H:%M:%S")
    echo "[$timestamp] $line"
done
