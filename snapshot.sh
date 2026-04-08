#!/bin/bash

# Disk Space Snapshot - 空间快照对比工具
# 每隔一段时间拍"快照"，对比哪些目录增长了

SNAPSHOT_DIR="$HOME/.disk_monitor_logs/snapshots"
mkdir -p "$SNAPSHOT_DIR"

timestamp=$(date "+%Y%m%d_%H%M%S")
snapshot_file="$SNAPSHOT_DIR/snapshot_$timestamp.txt"

echo "=== 磁盘空间快照 $(date) ===" > "$snapshot_file"
echo "" >> "$snapshot_file"

echo "总体状态:" >> "$snapshot_file"
df -h / >> "$snapshot_file"
echo "" >> "$snapshot_file"

echo "主要目录占用:" >> "$snapshot_file"
du -sh ~/Downloads ~/Library/Containers ~/Library/Caches ~/.ollama ~/Library/Developer 2>/dev/null >> "$snapshot_file"
echo "" >> "$snapshot_file"

echo "Downloads 前10大文件:" >> "$snapshot_file"
find ~/Downloads -type f -exec du -h {} \; 2>/dev/null | sort -hr | head -n 10 >> "$snapshot_file"
echo "" >> "$snapshot_file"

echo "✅ 快照已保存: $snapshot_file"

# 如果有之前的快照，进行对比
prev_snapshot=$(ls -t "$SNAPSHOT_DIR"/snapshot_*.txt 2>/dev/null | sed -n '2p')

if [ -n "$prev_snapshot" ]; then
    echo ""
    echo "📊 与上次快照对比:"
    echo "上次: $(basename $prev_snapshot)"
    echo ""
    
    # 对比总体空间
    prev_avail=$(grep "^/dev" "$prev_snapshot" | awk '{print $4}')
    curr_avail=$(grep "^/dev" "$snapshot_file" | awk '{print $4}')
    echo "可用空间: $prev_avail → $curr_avail"
    
    # 对比各目录
    echo ""
    echo "目录大小变化:"
    diff <(grep -A 10 "主要目录占用" "$prev_snapshot" | tail -n +2) \
         <(grep -A 10 "主要目录占用" "$snapshot_file" | tail -n +2) || true
fi

echo ""
echo "💾 所有快照: ls -lh $SNAPSHOT_DIR/"
