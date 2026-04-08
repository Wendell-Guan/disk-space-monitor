#!/bin/bash

# AI-Friendly Diagnostic Report Generator
# Generates a comprehensive report optimized for AI analysis

REPORT_FILE="$HOME/disk_space_ai_report_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" << 'REPORT_HEADER'
# Disk Space Diagnostic Report

**Generated:** $(date)
**Purpose:** Analyze unexpected disk space consumption

---

## Executive Summary

I'm experiencing rapid disk space loss on my macOS system. This report contains monitoring data to help identify the cause.

---

## 1. Current Disk Status

```
REPORT_HEADER

# Current disk status
echo "\`\`\`" >> "$REPORT_FILE"
df -h / >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION2'

---

## 2. Space Change Timeline

**Last 50 monitoring records:**

```
SECTION2

# Recent space changes
if [ -f ~/.disk_monitor_logs/emergency.log ]; then
    tail -50 ~/.disk_monitor_logs/emergency.log >> "$REPORT_FILE"
else
    echo "No emergency log found" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'SECTION3'
```

**Analysis needed:** Look for sudden drops in available space (e.g., 5472MB → 5300MB)

---

## 3. Alert Events (Space Loss >100MB)

```
SECTION3

# Emergency events
if [ -f ~/.disk_monitor_logs/emergency.log ]; then
    grep -A 20 "⚠️" ~/.disk_monitor_logs/emergency.log | tail -100 >> "$REPORT_FILE" 2>/dev/null || echo "No alerts found" >> "$REPORT_FILE"
else
    echo "No emergency log found" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << 'SECTION4'
```

---

## 4. Top Space Consumers

### Major Directories

```
SECTION4

# Top space consumers
du -sh ~/Downloads ~/Library/Containers ~/Library/Caches ~/.ollama ~/Library/Developer 2>/dev/null >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION5'
```

### Specific Culprits

```
SECTION5

# Specific problematic apps/folders
echo "=== WeChat ===" >> "$REPORT_FILE"
du -sh ~/Library/Containers/com.tencent.xinWeChat 2>/dev/null >> "$REPORT_FILE" || echo "Not found" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "=== Xcode/iOS Simulators ===" >> "$REPORT_FILE"
du -sh ~/Library/Developer/CoreSimulator ~/Library/Developer/Xcode 2>/dev/null >> "$REPORT_FILE" || echo "Not found" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "=== Ollama Models ===" >> "$REPORT_FILE"
du -sh ~/.ollama 2>/dev/null >> "$REPORT_FILE" || echo "Not found" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "=== Docker ===" >> "$REPORT_FILE"
docker system df 2>/dev/null >> "$REPORT_FILE" || echo "Docker not running" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION6'
```

---

## 5. Largest Files in Downloads

```
SECTION6

# Top 20 largest files
find ~/Downloads -type f -exec du -h {} \; 2>/dev/null | sort -hr | head -20 >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION7'
```

---

## 6. Recently Modified Large Files (Last 24 Hours)

```
SECTION7

# Files modified in last 24 hours >50MB
find ~/Downloads ~/Library/Caches -type f -size +50M -mtime -1 -exec ls -lh {} \; 2>/dev/null | head -30 >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION8'
```

---

## 7. Running Processes (Memory Usage)

```
SECTION8

# Top 15 processes by memory
ps aux | awk '{print $2, $3, $4, $11}' | sort -k3 -rn | head -15 >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION9'
```

---

## 8. Suspected Background Activities

### Ollama Status
```
SECTION9

ps aux | grep ollama | grep -v grep >> "$REPORT_FILE" || echo "Not running" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION10'
```

### Download Managers
```
SECTION10

ps aux | grep -E "download|wget|curl|aria2" | grep -v grep >> "$REPORT_FILE" || echo "None found" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION11'
```

### Homebrew
```
SECTION11

ps aux | grep brew | grep -v grep >> "$REPORT_FILE" || echo "Not running" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION12'
```

---

## 9. System Logs (Recent Errors)

```
SECTION12

# Recent system errors related to disk
log show --predicate 'eventMessage contains "disk" OR eventMessage contains "space"' --last 1h --style compact 2>/dev/null | tail -50 >> "$REPORT_FILE" || echo "Unable to retrieve system logs" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION13'
```

---

## 10. Time Machine Snapshots

```
SECTION13

tmutil listlocalsnapshots / 2>/dev/null >> "$REPORT_FILE" || echo "No local snapshots or unable to check" >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'SECTION14'
```

---

## 11. Temporary Files

```
SECTION14

du -sh /private/var/folders/* 2>/dev/null | sort -hr | head -10 >> "$REPORT_FILE"

cat >> "$REPORT_FILE" << 'QUESTIONS'
```

---

## Questions for AI Analysis

Please analyze the above data and answer:

1. **What is likely causing the rapid disk space consumption?**
   - Look for patterns in Section 2 (timeline)
   - Check Section 3 for sudden space loss events
   - Identify suspicious processes or files

2. **Is the space loss continuous or intermittent?**
   - Analyze the monitoring timeline
   - Look for specific time patterns

3. **What are the top 3 culprits?**
   - Based on directory sizes (Section 4)
   - Based on recent file changes (Section 6, 7)
   - Based on running processes (Section 7, 8)

4. **Recommended actions:**
   - What should I delete/clean first?
   - What processes should I stop?
   - What settings should I change?

5. **Is this normal behavior or a bug/misconfiguration?**
   - Compare against typical macOS space usage patterns

---

## Additional Context

- **Expected behavior:** Disk space should be relatively stable
- **Actual behavior:** Space disappears rapidly (40GB → 5GB)
- **Timeline:** [Fill in when this started]
- **Recent changes:** [Fill in any recent software installations, updates, etc.]

QUESTIONS

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "**Report saved to:** $REPORT_FILE" >> "$REPORT_FILE"

# Output
echo "✅ AI-friendly report generated!"
echo ""
echo "📄 Report location:"
echo "   $REPORT_FILE"
echo ""
echo "📋 Next steps:"
echo "   1. Open the report: open '$REPORT_FILE'"
echo "   2. Copy all content (Cmd+A, Cmd+C)"
echo "   3. Paste to Claude and ask: 'Please analyze this disk space report'"
echo ""
echo "🤖 Suggested prompt for Claude:"
echo "   I'm experiencing rapid disk space loss on macOS."
echo "   Here's a diagnostic report. Please identify the cause"
echo "   and suggest solutions."

# Auto-open the report
open "$REPORT_FILE"
