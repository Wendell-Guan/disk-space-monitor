# 创建 macOS 应用程序

本项目可以创建一个真正的 macOS 应用程序，像其他应用一样双击启动！

## 自动创建应用（推荐）

运行以下命令自动创建应用：

```bash
./create_macos_app.sh
```

应用将被创建在 `~/Applications/DiskSpaceMonitor.app`

## 手动创建应用

如果需要手动创建，按照以下步骤：

### 1. 创建应用包结构

```bash
mkdir -p ~/Applications/DiskSpaceMonitor.app/Contents/MacOS
mkdir -p ~/Applications/DiskSpaceMonitor.app/Contents/Resources
```

### 2. 创建 Info.plist

在 `~/Applications/DiskSpaceMonitor.app/Contents/` 目录下创建 `Info.plist` 文件：

```xml
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
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
```

### 3. 创建启动脚本

在 `~/Applications/DiskSpaceMonitor.app/Contents/MacOS/` 目录下创建 `DiskSpaceMonitor` 文件：

```bash
#!/bin/bash
pkill -f "statusbar_app" 2>/dev/null
cd ~/disk-space-monitor
python3 statusbar_app_zh.py &
```

然后设置执行权限：
```bash
chmod +x ~/Applications/DiskSpaceMonitor.app/Contents/MacOS/DiskSpaceMonitor
```

### 4. 复制图标

```bash
cp hard_drive_icon.png ~/Applications/DiskSpaceMonitor.app/Contents/Resources/AppIcon.png
```

## 使用应用

创建完成后，你可以：

1. **双击启动** - 在 Finder 中打开 `~/Applications/` 文件夹，双击 `DiskSpaceMonitor.app`
2. **添加到 Dock** - 拖动应用到 Dock 栏
3. **开机自启** - 在系统设置 → 通用 → 登录项中添加

## 注意事项

- 应用会自动关闭之前运行的实例（避免重复运行）
- 应用使用中文界面（statusbar_app_zh.py）
- 如需英文版，修改启动脚本中的 `statusbar_app_zh.py` 为 `statusbar_app.py`
