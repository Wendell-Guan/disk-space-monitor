#!/bin/bash

# Enhanced Disk Space Monitor - 增强版空间监控
# 追踪缓存、临时文件、系统文件的变化

LOG_FILE="$HOME/.disk_monitor_logs/enhanced.log"
mkdir -p "$HOME/.disk_monitor_logs"

echo "=== 增强磁盘监控启动 $(date) ===" | tee -a "$LOG_FILE"
echo "监控内容：磁盘空间 + 缓存大小 + 临时文件" | tee -a "$LOG_FILE"
echo ""

get_avail_mb() {
    df -m / | tail -n 1 | awk '{print $4}'
}

get_cache_size() {
    du -sm ~/Library/Caches 2>/dev/null | awk '{print $1}'
}

get_chrome_cache() {
    du -sm ~/Library/Caches/Google 2>/dev/null | awk '{print $1}'
}

get_temp_size() {
    du -sm /private/var/folders 2>/dev/null | awk '{print $1}'
}

last_avail=$(get_avail_mb)
last_cache=$(get_cache_size)
last_chrome=$(get_chrome_cache)
last_temp=$(get_temp_size)

while true; do
    current_avail=$(get_avail_mb)
    current_cache=$(get_cache_size)
    current_chrome=$(get_chrome_cache)
    current_temp=$(get_temp_size)
    
    diff_avail=$((last_avail - current_avail))
    diff_cache=$((current_cache - last_cache))
    diff_chrome=$((current_chrome - last_chrome))
    diff_temp=$((current_temp - last_temp))
    
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 如果空间减少超过50MB，或者缓存增加超过50MB
    if [ $diff_avail -gt 50 ] || [ $diff_cache -gt 50 ] || [ $diff_chrome -gt 30 ]; then
        echo "" | tee -a "$LOG_FILE"
        echo "🔍 [$timestamp] 发现变化！" | tee -a "$LOG_FILE"
        echo "  💾 可用空间: ${current_avail}MB (变化: ${diff_avail}MB)" | tee -a "$LOG_FILE"
        echo "  📦 总缓存: ${current_cache}MB (变化: +${diff_cache}MB)" | tee -a "$LOG_FILE"
        echo "  🌐 Chrome缓存: ${current_chrome}MB (变化: +${diff_chrome}MB)" | tee -a "$LOG_FILE"
        echo "  📁 临时文件: ${current_temp}MB (变化: +${diff_temp}MB)" | tee -a "$LOG_FILE"
        echo "" | tee -a "$LOG_FILE"
        
        # 详细分析
        if [ $diff_chrome -gt 20 ]; then
            echo "  ⚠️  Chrome 缓存快速增长！建议关闭标签页" | tee -a "$LOG_FILE"
        fi
        
        if [ $diff_temp -gt 50 ]; then
            echo "  ⚠️  临时文件增长！可能是系统日志或崩溃报告" | tee -a "$LOG_FILE"
        fi
        
        # Top 5 cache directories
        echo "  📊 最大缓存目录：" | tee -a "$LOG_FILE"
        du -sm ~/Library/Caches/* 2>/dev/null | sort -rn | head -5 | while read size dir; do
            echo "    ${size}MB - $(basename "$dir")" | tee -a "$LOG_FILE"
        done
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG_FILE"
    else
        # 正常记录（每分钟一次，减少日志量）
        if [ $(($(date +%s) % 60)) -eq 0 ]; then
            echo "[$timestamp] 可用:${current_avail}MB | 缓存:${current_cache}MB | Chrome:${current_chrome}MB" | tee -a "$LOG_FILE"
        fi
    fi
    
    last_avail=$current_avail
    last_cache=$current_cache
    last_chrome=$current_chrome
    last_temp=$current_temp
    
    sleep 10
done
