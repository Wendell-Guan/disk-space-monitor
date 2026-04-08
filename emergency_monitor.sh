#!/bin/bash

# Emergency Disk Space Monitor - 紧急空间监控
# 每5秒检查一次，发现空间快速减少时立即记录详情

LOG_FILE="$HOME/.disk_monitor_logs/emergency.log"
mkdir -p "$HOME/.disk_monitor_logs"

echo "=== 紧急磁盘监控启动 $(date) ===" | tee -a "$LOG_FILE"
echo "每5秒检查，如发现空间减少超过100MB将记录详情" | tee -a "$LOG_FILE"
echo ""

# 获取初始可用空间（单位：MB）
get_avail_mb() {
    df -m / | tail -n 1 | awk '{print $4}'
}

last_avail=$(get_avail_mb)
alert_threshold=100  # MB

while true; do
    current_avail=$(get_avail_mb)
    diff=$((last_avail - current_avail))
    
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [ $diff -gt $alert_threshold ]; then
        echo "" | tee -a "$LOG_FILE"
        echo "⚠️  [$timestamp] 警告：空间减少 ${diff}MB！" | tee -a "$LOG_FILE"
        echo "    之前: ${last_avail}MB | 现在: ${current_avail}MB" | tee -a "$LOG_FILE"
        echo "" | tee -a "$LOG_FILE"
        
        # 记录当时运行的可疑进程
        echo "  📊 当时的进程状态：" >> "$LOG_FILE"
        ps aux | sort -k4 -rn | head -n 15 >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        
        # 记录最近创建/修改的大文件
        echo "  📦 最近5分钟修改的大文件（>50MB）：" >> "$LOG_FILE"
        find ~/Downloads ~/Library/Caches -type f -size +50M -mmin -5 -exec ls -lh {} \; 2>/dev/null >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
    else
        echo "[$timestamp] 正常 - 可用: ${current_avail}MB (变化: ${diff}MB)" | tee -a "$LOG_FILE"
    fi
    
    last_avail=$current_avail
    sleep 5
done
