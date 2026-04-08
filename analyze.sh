#!/bin/bash

# Disk Space Analyzer - 日志分析工具

LOG_DIR="${LOG_DIR:-$HOME/.disk_monitor_logs}"

if [ ! -d "$LOG_DIR" ]; then
    echo "错误：日志目录不存在 - $LOG_DIR"
    echo "请先运行 monitor.sh 开始监控"
    exit 1
fi

echo "=== 磁盘空间监控分析报告 ==="
echo ""

# 1. 空间变化趋势
echo "📊 空间变化趋势："
if [ -f "$LOG_DIR/disk_space.log" ]; then
    first_line=$(grep "已用:" "$LOG_DIR/disk_space.log" | head -n 1)
    last_line=$(grep "已用:" "$LOG_DIR/disk_space.log" | tail -n 1)
    
    echo "  开始: $first_line"
    echo "  当前: $last_line"
    echo ""
    
    total_lines=$(grep -c "已用:" "$LOG_DIR/disk_space.log")
    echo "  总记录数: $total_lines"
else
    echo "  无数据"
fi

echo ""

# 2. 最占用资源的进程
echo "💻 资源占用最高的进程（最近10条）："
if [ -f "$LOG_DIR/disk_writers.log" ]; then
    tail -n 50 "$LOG_DIR/disk_writers.log" | grep -v "^---" | grep -v "磁盘写入进程" | sort -k3 -rn | head -n 10
else
    echo "  无数据"
fi

echo ""

# 3. 大文件统计
echo "📦 发现的大文件："
if [ -f "$LOG_DIR/large_files.log" ]; then
    grep -v "^---" "$LOG_DIR/large_files.log" | grep -v "扫描大文件" | tail -n 10
else
    echo "  无数据"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "完整日志位置: $LOG_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
