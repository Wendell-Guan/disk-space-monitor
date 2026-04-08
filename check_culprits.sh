#!/bin/bash

# Check Common Disk Space Culprits - 检查常见空间占用者

echo "=== 磁盘空间占用分析 ==="
echo ""

echo "1️⃣  检查 Ollama 模型..."
if [ -d ~/.ollama/models ]; then
    echo "Ollama 模型占用："
    du -sh ~/.ollama 2>/dev/null
    echo ""
fi

echo "2️⃣  检查 Docker..."
if command -v docker &> /dev/null; then
    echo "Docker 占用："
    docker system df 2>/dev/null || echo "Docker 未运行"
    echo ""
fi

echo "3️⃣  检查微信缓存..."
wechat_path="$HOME/Library/Containers/com.tencent.xinWeChat"
if [ -d "$wechat_path" ]; then
    echo "微信占用："
    du -sh "$wechat_path" 2>/dev/null
    echo ""
fi

echo "4️⃣  检查 Xcode..."
if [ -d "$HOME/Library/Developer" ]; then
    echo "Xcode 相关占用："
    du -sh "$HOME/Library/Developer/CoreSimulator" 2>/dev/null
    du -sh "$HOME/Library/Developer/Xcode" 2>/dev/null
    echo ""
fi

echo "5️⃣  检查 Homebrew 缓存..."
if [ -d "$HOME/Library/Caches/Homebrew" ]; then
    echo "Homebrew 缓存："
    du -sh "$HOME/Library/Caches/Homebrew" 2>/dev/null
    echo ""
fi

echo "6️⃣  检查系统日志..."
echo "系统日志占用："
du -sh /private/var/log 2>/dev/null
echo ""

echo "7️⃣  检查下载文件夹前20大文件..."
du -sh "$HOME/Downloads" 2>/dev/null
find "$HOME/Downloads" -type f -exec du -h {} \; 2>/dev/null | sort -hr | head -n 20
echo ""

echo "8️⃣  检查临时文件..."
echo "临时文件占用："
du -sh /private/var/folders/42 2>/dev/null
echo ""

echo "9️⃣  检查是否有进程在下载..."
echo "可疑的下载/写入进程："
ps aux | grep -E "download|wget|curl|ollama pull|brew" | grep -v grep
echo ""

echo "🔟 当前磁盘状态："
df -h /
