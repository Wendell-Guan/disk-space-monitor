# 💾 磁盘空间监控 - 状态栏应用

macOS 状态栏应用，实时显示磁盘空间使用情况

## 功能预览

**状态栏显示**：
```
💾 5.4GB  ← 显示可用空间
```

**点击菜单显示**：
- ✅ 已用空间
- ✅ 可用空间  
- ✅ 使用率
- 🟢 监控状态（运行中/未运行）
- 📊 查看监控日志
- 📸 创建快照
- 🔍 打开监控文件夹
- 🧹 快速清理工具
  - 清理 Xcode 模拟器
  - 清理 Homebrew 缓存
  - 打开下载文件夹
- 🔄 刷新

## 安装步骤

### 1. 安装依赖

```bash
cd ~/disk-space-monitor
./install_gui.sh
```

这会安装 Python 库 `rumps`（用于创建状态栏应用）

### 2. 启动应用

```bash
./launch_gui.sh
```

或者直接运行：
```bash
python3 statusbar_app.py
```

### 3. 查看状态栏

启动后，在 macOS 状态栏右上角会看到 **💾** 图标，点击即可查看详情

## 开机自启（可选）

### 方法 1：使用 LaunchAgent

```bash
cat > ~/Library/LaunchAgents/com.diskmonitor.statusbar.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.diskmonitor.statusbar</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>/Users/你的用户名/disk-space-monitor/statusbar_app.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
PLIST

# 加载
launchctl load ~/Library/LaunchAgents/com.diskmonitor.statusbar.plist
```

记得修改 `/Users/你的用户名/` 为你的实际路径！

### 方法 2：系统设置

1. 打开「系统设置」
2. 「通用」→「登录项」
3. 点击 「+」添加项目
4. 选择 `~/disk-space-monitor/statusbar_app.py`

## 截图

```
┌─────────────────────────────────┐
│ 💾 5.4GB                     ▼ │  ← 状态栏
└─────────────────────────────────┘

点击后显示菜单：
┌─────────────────────────────────┐
│ 已用空间: 10Gi                  │
│ 可用空间: 5.4Gi                 │
│ 使用率: 67%                     │
│ ────────────────────────────── │
│ 🟢 监控状态: 运行中              │
│ ────────────────────────────── │
│ 📊 查看监控日志                  │
│ 📸 创建快照                      │
│ 🔍 打开监控文件夹                │
│ ────────────────────────────── │
│ 🧹 快速清理              ▶      │
│ ────────────────────────────── │
│ 🔄 刷新                         │
│ ❌ 退出                         │
└─────────────────────────────────┘
```

## 特性

- 🔄 **自动更新** - 每30秒自动刷新数据
- 🟢 **监控状态** - 实时显示后台监控是否运行
- 📊 **快速访问** - 一键打开日志和监控文件夹
- 🧹 **快速清理** - 集成常用清理工具
- 💾 **轻量级** - 内存占用小于 20MB

## 故障排除

### 应用无法启动

```bash
# 检查依赖
python3 -c "import rumps"

# 如果报错，重新安装
pip3 install rumps pyobjc
```

### 状态栏没有图标

- 检查应用是否在运行：`ps aux | grep statusbar_app`
- 重启应用：`pkill -f statusbar_app && python3 ~/disk-space-monitor/statusbar_app.py &`

### 监控状态显示未运行

- 启动后台监控：`~/disk-space-monitor/emergency_monitor.sh &`

## 技术栈

- **Python 3** - 应用逻辑
- **rumps** - macOS 状态栏框架
- **pyobjc** - Python-Objective-C 桥接

## 开源协议

MIT License
