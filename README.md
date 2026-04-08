# Disk Space Monitor 💾

macOS 磁盘空间监控工具 - 追踪和分析磁盘空间快速消耗的原因

## 功能特性

- 🔍 **持续监控**：自动记录磁盘空间变化
- 📊 **进程追踪**：记录占用资源最多的进程
- 📦 **大文件检测**：定期扫描并记录大文件
- 🚀 **实时监控**：实时查看文件写入活动
- 📈 **分析报告**：生成可读性强的分析报告

## 快速开始

### 1. 启动监控（后台运行）

```bash
./monitor.sh &
```

监控日志将保存在 `~/.disk_monitor_logs/`

### 2. 查看分析报告

```bash
./analyze.sh
```

### 3. 实时监控文件写入

```bash
sudo ./realtime.sh
```

### 4. 停止监控

```bash
pkill -f monitor.sh
```

## 配置

可以通过环境变量自定义配置：

```bash
# 自定义日志目录
export LOG_DIR="/path/to/logs"

# 自定义监控间隔（秒）
export INTERVAL=60

# 自定义大文件阈值
export LARGE_FILE_SIZE=500M

./monitor.sh &
```

## 日志文件

监控系统会生成以下日志文件：

- `disk_space.log` - 磁盘空间变化记录（每30秒）
- `disk_writers.log` - 进程资源占用记录
- `large_files.log` - 大文件扫描结果（每5分钟）

## 使用场景

### 场景1：磁盘空间快速消失

1. 启动监控：`./monitor.sh &`
2. 等待一段时间（几小时或过夜）
3. 查看分析报告：`./analyze.sh`
4. 对比开始和结束的空间使用情况

### 场景2：找出占用空间的程序

1. 运行实时监控：`sudo ./realtime.sh`
2. 观察输出，频繁出现的进程名即为可疑对象
3. 按 Ctrl+C 停止

### 场景3：定期检查磁盘健康

在 crontab 中添加定期检查：

```bash
# 每小时记录一次
0 * * * * ~/disk-space-monitor/monitor.sh
```

## 手动调查命令

```bash
# 查看实时空间变化
tail -f ~/.disk_monitor_logs/disk_space.log

# 查看完整历史
cat ~/.disk_monitor_logs/disk_space.log

# 查看进程记录
tail -20 ~/.disk_monitor_logs/disk_writers.log

# 查看大文件
cat ~/.disk_monitor_logs/large_files.log

# 检查当前磁盘状态
df -h /

# 交互式目录扫描（需要先安装 ncdu）
ncdu ~/
```

## 系统要求

- macOS
- Bash
- sudo 权限（用于实时监控）

## 可选工具

安装以下工具以增强功能：

```bash
# 交互式磁盘使用分析工具
brew install ncdu

# 现代化的磁盘使用分析工具
brew install dust
```

## 故障排除

### 监控未启动

检查进程：
```bash
ps aux | grep monitor.sh
```

### 日志文件不存在

确保已启动监控：
```bash
ls -lh ~/.disk_monitor_logs/
```

### 权限不足

实时监控需要 sudo 权限：
```bash
sudo ./realtime.sh
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 开源协议

MIT License

## 作者

您的名字

---

**提示**：如果发现微信、Xcode 等应用占用大量空间，建议：
- 清理微信缓存（设置 → 通用 → 储存空间）
- 删除 Xcode 模拟器：`xcrun simctl delete unavailable`
- 清理 Homebrew 缓存：`brew cleanup`
