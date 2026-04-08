#!/bin/bash

# Continuous Monitor with Detailed Logging
# Tracks every change with context for AI analysis

LOG_FILE="$HOME/.disk_monitor_logs/detailed_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$HOME/.disk_monitor_logs"

echo "=== Detailed Continuous Monitor Started ===" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "This log tracks every disk change with full context for AI analysis" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Initial snapshot
echo "INITIAL STATE:" >> "$LOG_FILE"
df -h / >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

last_avail=$(df -m / | tail -n 1 | awk '{print $4}')
counter=0

while true; do
    current_avail=$(df -m / | tail -n 1 | awk '{print $4}')
    diff=$((last_avail - current_avail))
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Log every change, even small ones
    if [ $diff -ne 0 ]; then
        counter=$((counter + 1))
        
        echo "" >> "$LOG_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
        echo "EVENT #$counter - [$timestamp]" >> "$LOG_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
        
        if [ $diff -gt 0 ]; then
            echo "⬇️  SPACE DECREASED: ${diff}MB (${last_avail}MB → ${current_avail}MB)" >> "$LOG_FILE"
        else
            echo "⬆️  SPACE INCREASED: $((-diff))MB (${last_avail}MB → ${current_avail}MB)" >> "$LOG_FILE"
        fi
        
        echo "" >> "$LOG_FILE"
        echo "Running processes at this moment:" >> "$LOG_FILE"
        ps aux | awk '{print $2, $3, $4, $11}' | sort -k3 -rn | head -10 >> "$LOG_FILE"
        
        echo "" >> "$LOG_FILE"
        echo "Active file operations (5 second sample):" >> "$LOG_FILE"
        timeout 5 sudo fs_usage -w -f filesys 2>/dev/null | grep -E "WrData|write" | head -20 >> "$LOG_FILE" 2>&1 || echo "Unable to capture" >> "$LOG_FILE"
        
        # If significant change (>10MB), capture more details
        if [ ${diff#-} -gt 10 ]; then
            echo "" >> "$LOG_FILE"
            echo "🔍 SIGNIFICANT CHANGE DETECTED - Additional details:" >> "$LOG_FILE"
            
            echo "Recent large file modifications:" >> "$LOG_FILE"
            find ~/Downloads ~/Library/Caches -type f -size +10M -mmin -2 -exec ls -lh {} \; 2>/dev/null | head -10 >> "$LOG_FILE"
            
            echo "" >> "$LOG_FILE"
            echo "Network activity:" >> "$LOG_FILE"
            netstat -an | grep ESTABLISHED | head -10 >> "$LOG_FILE"
        fi
        
        echo "" >> "$LOG_FILE"
    fi
    
    last_avail=$current_avail
    sleep 5
done
