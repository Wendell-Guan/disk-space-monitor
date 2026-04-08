#!/bin/bash

# Disk Space Monitor - 磁盘空间监控工具
# 持续监控磁盘空间变化，记录占用进程和大文件

# 配置
LOG_DIR="${LOG_DIR:-$HOME/.disk_monitor_logs}"
INTERVAL="${INTERVAL:-30}"  # 监控间隔（秒）
LARGE_FILE_SIZE="${LARGE_FILE_SIZE:-100M}"  # 大文件阈值

# 创建日志目录
mkdir -p "$LOG_DIR"

DISK_LOG="$LOG_DIR/disk_space.log"
PROCESS_LOG="$LOG_DIR/disk_writers.log"
LARGE_FILES_LOG="$LOG_DIR/large_files.log"

echo "=== 磁盘监控系统已启动 ===" | tee -a "$DISK_LOG"
echo "日志目录: $LOG_DIR"
echo "监控间隔: ${INTERVAL}秒"
echo "开始时间: $(date)" | tee -a "$DISK_LOG"
echo ""

# 记录初始状态
df -h / >> "$DISK_LOG"
echo "---" >> "$DISK_LOG"

while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 1. 记录磁盘空间变化
    disk_info=$(df -h / | tail -n 1)
    used=$(echo $disk_info | awk '{print $3}')
    avail=$(echo $disk_info | awk '{print $4}')
    percent=$(echo $disk_info | awk '{print $5}')
    
    echo "[$timestamp] 已用: $used | 可用: $avail | 使用率: $percent" | tee -a "$DISK_LOG"
    
    # 2. 记录占用磁盘最多的进程
    echo "[$timestamp] 磁盘写入进程:" >> "$PROCESS_LOG"
    ps aux | awk '{print $2, $3, $4, $11}' | sort -k3 -rn | head -n 10 >> "$PROCESS_LOG"
    echo "---" >> "$PROCESS_LOG"
    
    # 3. 每5分钟记录一次大文件变化
    if [ $(($(date +%s) % 300)) -lt $INTERVAL ]; then
        echo "[$timestamp] 扫描大文件..." >> "$LARGE_FILES_LOG"
        find ~/Downloads ~/Library/Caches -type f -size +$LARGE_FILE_SIZE -exec ls -lh {} \; 2>/dev/null | head -n 20 >> "$LARGE_FILES_LOG"
        echo "---" >> "$LARGE_FILES_LOG"
    fi
    
    sleep $INTERVAL
done
