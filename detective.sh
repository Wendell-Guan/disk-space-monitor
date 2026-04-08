#!/bin/bash

# Disk Space Detective - 磁盘空间侦探
# 持续监控并记录所有写入活动，找出间歇性空间消耗

LOG_FILE="$HOME/.disk_monitor_logs/detective.log"
ACTIVITY_LOG="$HOME/.disk_monitor_logs/file_activity.log"
mkdir -p "$HOME/.disk_monitor_logs"

echo "=== 磁盘空间侦探启动 $(date) ===" | tee -a "$LOG_FILE"
echo "正在监控所有文件写入活动..." | tee -a "$LOG_FILE"
echo "日志位置: $ACTIVITY_LOG"
echo ""

# 启动文件活动监控（后台）
(
    echo "=== 文件写入活动记录 $(date) ===" > "$ACTIVITY_LOG"
    sudo fs_usage -w -f filesys 2>/dev/null | while read line; do
        # 只记录真正的写入操作，过滤掉缓存读取
        if echo "$line" | grep -qE "WrData|write.*[0-9]+M|write.*[0-9]+G"; then
            timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N")
            echo "[$timestamp] $line" >> "$ACTIVITY_LOG"
        fi
    done
) &

FS_USAGE_PID=$!
echo "文件活动监控 PID: $FS_USAGE_PID" >> "$LOG_FILE"

# 每10秒统计写入最多的进程
while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 统计过去10秒内的文件活动
    if [ -f "$ACTIVITY_LOG" ]; then
        echo "" >> "$LOG_FILE"
        echo "[$timestamp] 写入活动统计:" >> "$LOG_FILE"
        
        # 从活动日志中提取进程名并统计
        tail -n 1000 "$ACTIVITY_LOG" | awk '{print $(NF)}' | sort | uniq -c | sort -rn | head -n 10 >> "$LOG_FILE"
        echo "---" >> "$LOG_FILE"
    fi
    
    sleep 10
done
