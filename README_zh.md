# 磁盘空间监控 💾

macOS 磁盘空间监控工具 - 追踪和分析什么在消耗你的磁盘空间

[English](README.md) | [中文](README_zh.md)

## 功能特性

- 🔍 **持续监控** - 自动记录磁盘空间变化
- 📊 **进程追踪** - 记录占用资源最多的进程
- 📦 **大文件检测** - 定期扫描并记录大文件
- 🚀 **实时监控** - 实时查看文件写入活动
- 📈 **分析报告** - 生成可读性强的分析报告
- 💻 **状态栏应用** - 状态栏实时显示磁盘使用情况

## 快速开始

### 安装

```bash
cd ~/disk-space-monitor
./install_gui.sh
```

### 启动监控

**方式1：命令行（后台）**
```bash
./emergency_monitor.sh &
```

**方式2：GUI 状态栏应用**
```bash
./launch_gui.sh
```

启动后在状态栏会看到 💾 图标显示可用空间。

## 组件说明

### 📱 状态栏应用（推荐）

点击 💾 图标可以:
- 查看已用/可用空间
- 查看监控状态
- 快速访问日志
- 快速清理工具
- 每30秒自动刷新

### 🖥️ 命令行工具

| 脚本 | 功能 | 更新频率 |
|-----|------|---------|
| `monitor.sh` | 常规监控 | 每30秒 |
| `emergency_monitor.sh` | 空间减少>100MB时警报 | 每5秒 |
| `analyze.sh` | 生成分析报告 | 按需 |
| `snapshot.sh` | 创建空间快照 | 按需 |
| `check_culprits.sh` | 快速诊断 | 按需 |

## 使用方法

### 监控空间变化

```bash
# 查看实时紧急日志
tail -f ~/.disk_monitor_logs/emergency.log

# 创建快照对比
~/disk-space-monitor/snapshot.sh

# 运行诊断
~/disk-space-monitor/check_culprits.sh

# 生成分析报告
~/disk-space-monitor/analyze.sh
```

### 状态栏应用

启动后:
1. 查看状态栏 💾 图标（显示可用空间）
2. 点击查看详细菜单
3. 访问日志、创建快照或使用快速清理工具

## 日志文件

所有日志保存在 `~/.disk_monitor_logs/`:

- `disk_space.log` - 磁盘空间变化历史
- `disk_writers.log` - 进程资源占用
- `large_files.log` - 大文件扫描结果
- `emergency.log` - 紧急事件（空间突然减少）
- `snapshots/` - 快照对比数据

## 使用场景

### 场景1：磁盘空间快速消失

1. 启动监控：`./emergency_monitor.sh &`
2. 等待一段时间（几小时或过夜）
3. 查看分析：`./analyze.sh`
4. 对比开始和结束的空间使用

### 场景2：找出占用空间的程序

1. 运行实时监控：`sudo ./realtime.sh`
2. 观察频繁出现的进程名
3. 按 Ctrl+C 停止

### 场景3：定期检查

添加到 crontab 定期检查:

```bash
# 每小时检查一次
0 * * * * ~/disk-space-monitor/monitor.sh
```

## 手动调查

```bash
# 查看实时空间变化
tail -f ~/.disk_monitor_logs/emergency.log

# 查看完整历史
cat ~/.disk_monitor_logs/disk_space.log

# 查看进程记录
tail -20 ~/.disk_monitor_logs/disk_writers.log

# 查看大文件
cat ~/.disk_monitor_logs/large_files.log

# 检查当前磁盘状态
df -h /

# 交互式目录扫描（需要 ncdu）
ncdu ~/
```

## 开机自启

### 方法1：LaunchAgent

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

### 方法2：系统设置

1. 打开「系统设置」
2. 「通用」→「登录项」
3. 点击 + 添加项目
4. 选择 `~/disk-space-monitor/statusbar_app.py`

## 系统要求

- macOS 10.13+
- Python 3.7+
- Bash
- sudo 权限（用于实时监控）

## 可选依赖

```bash
# 交互式磁盘使用分析工具
brew install ncdu

# 现代化磁盘使用分析工具
brew install dust
```

## 配置

通过环境变量自定义:

```bash
# 自定义日志目录
export LOG_DIR="/path/to/logs"

# 自定义监控间隔（秒）
export INTERVAL=60

# 自定义大文件阈值
export LARGE_FILE_SIZE=500M

./monitor.sh &
```

## 故障排除

### 状态栏应用无法启动

```bash
# 检查依赖
python3 -c "import rumps"

# 如果报错，重新安装
pip3 install rumps pyobjc
```

### 状态栏没有图标

- 检查是否在运行：`ps aux | grep statusbar_app`
- 重启应用：`pkill -f statusbar_app && python3 ~/disk-space-monitor/statusbar_app.py &`

### 监控状态显示未运行

- 启动监控：`~/disk-space-monitor/emergency_monitor.sh &`

## 常见空间占用者

根据分析，常见的空间消耗者：

1. **Xcode 模拟器** (~34GB) - `xcrun simctl delete unavailable`
2. **微信缓存** (~48GB) - 微信设置中清理
3. **Downloads** (~187GB) - 检查并删除旧文件
4. **Homebrew 缓存** - `brew cleanup`
5. **Docker** - `docker system prune -a`

## 贡献

欢迎提交 Issue 和 Pull Request！

## 作者

Wendell-Guan

## 开源协议

MIT License - 详见 [LICENSE](LICENSE) 文件

## 鸣谢

- 使用 [rumps](https://github.com/jaredks/rumps) 构建状态栏应用
- 使用 macOS 原生工具（df、fs_usage、ps 等）

---

**提示**：如果发现微信、Xcode 等应用占用大量空间：
- 清理微信：设置 → 通用 → 储存空间
- 删除 Xcode 模拟器：`xcrun simctl delete unavailable`
- 清理 Homebrew：`brew cleanup`
