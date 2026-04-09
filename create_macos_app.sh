#!/bin/bash

# 自动创建 macOS 应用程序

echo "🚀 开始创建 macOS 应用程序..."

APP_DIR="$HOME/Applications/DiskSpaceMonitor.app"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. 创建应用包结构
echo "📁 创建应用包结构..."
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# 2. 创建 Info.plist
echo "📝 创建 Info.plist..."
cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DiskSpaceMonitor</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.wendell.diskspacemonitor</string>
    <key>CFBundleName</key>
    <string>磁盘空间监控</string>
    <key>CFBundleDisplayName</key>
    <string>磁盘空间监控</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

# 3. 创建启动脚本
echo "🔧 创建启动脚本..."
cat > "$APP_DIR/Contents/MacOS/DiskSpaceMonitor" << 'LAUNCHER'
#!/bin/bash

# 先停止已运行的实例
pkill -f "statusbar_app" 2>/dev/null

# 启动应用
cd ~/disk-space-monitor
python3 statusbar_app_zh.py &
LAUNCHER

chmod +x "$APP_DIR/Contents/MacOS/DiskSpaceMonitor"

# 4. 复制图标
echo "🎨 复制图标..."
if [ -f "$SCRIPT_DIR/hard_drive_icon.png" ]; then
    cp "$SCRIPT_DIR/hard_drive_icon.png" "$APP_DIR/Contents/Resources/AppIcon.png"
    echo "✅ 图标已复制"
else
    echo "⚠️  图标文件未找到，使用默认图标"
fi

echo ""
echo "✅ 应用创建完成！"
echo ""
echo "📍 应用位置: $APP_DIR"
echo ""
echo "使用方法:"
echo "  1. 打开 Finder → Applications 文件夹"
echo "  2. 双击 '磁盘空间监控' 应用"
echo "  3. 查看菜单栏右上角 💾 图标"
echo ""
echo "提示: 你可以将应用拖到 Dock 栏以便快速访问"
echo ""

# 打开 Applications 文件夹
open ~/Applications/
