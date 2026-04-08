# Disk Space Monitor 💾

A macOS disk space monitoring tool that tracks and analyzes what's consuming your disk space.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-10.13+-blue.svg)](https://www.apple.com/macos/)
[![Python](https://img.shields.io/badge/Python-3.7+-green.svg)](https://www.python.org/)

[English](README.md) | [中文](README_zh.md)

## Features

- 🔍 **Continuous Monitoring** - Automatically track disk space changes
- 📊 **Process Tracking** - Record processes consuming the most resources
- 📦 **Large File Detection** - Periodically scan and log large files
- 🚀 **Real-time Monitoring** - View file write activity in real-time
- 📈 **Analysis Reports** - Generate readable analysis reports
- 💻 **Menu Bar App** - Real-time disk usage display in status bar

## Quick Start

### Installation

```bash
cd ~/disk-space-monitor
./install_gui.sh
```

### Launch Monitoring

**Option 1: Command Line (Background)**
```bash
./emergency_monitor.sh &
```

**Option 2: GUI Menu Bar App**
```bash
./launch_gui.sh
```

You'll see a 💾 icon in the menu bar showing available space.

## Components

### 📱 Menu Bar App (Recommended)

Click the 💾 icon to:
- View used/available space
- Check monitor status
- Access logs quickly
- Quick cleanup tools
- Auto-refresh every 30 seconds

### 🖥️ Command Line Tools

| Script | Function | Update Frequency |
|--------|----------|------------------|
| `monitor.sh` | Regular monitoring | Every 30s |
| `emergency_monitor.sh` | Alert when >100MB lost | Every 5s |
| `analyze.sh` | Generate analysis report | On-demand |
| `snapshot.sh` | Create space snapshot | On-demand |
| `check_culprits.sh` | Quick diagnostics | On-demand |

## Usage

### Monitor Space Changes

```bash
# View real-time emergency log
tail -f ~/.disk_monitor_logs/emergency.log

# Create snapshot for comparison
~/disk-space-monitor/snapshot.sh

# Run diagnostics
~/disk-space-monitor/check_culprits.sh

# Generate analysis report
~/disk-space-monitor/analyze.sh
```

### Menu Bar App

After launching:
1. Check the 💾 icon in menu bar (shows available space)
2. Click to view detailed menu
3. Access logs, create snapshots, or use quick cleanup tools

## Log Files

All logs are stored in `~/.disk_monitor_logs/`:

- `disk_space.log` - Disk space change history
- `disk_writers.log` - Process resource usage
- `large_files.log` - Large file scan results
- `emergency.log` - Emergency events (sudden space loss)
- `snapshots/` - Snapshot comparison data

## Use Cases

### Scenario 1: Disk Space Disappearing Fast

1. Start monitoring: `./emergency_monitor.sh &`
2. Wait (hours or overnight)
3. Check analysis: `./analyze.sh`
4. Compare start/end space usage

### Scenario 2: Find Space-Consuming Programs

1. Run real-time monitor: `sudo ./realtime.sh`
2. Watch output for frequent processes
3. Press Ctrl+C to stop

### Scenario 3: Regular Health Checks

Add to crontab for periodic checks:

```bash
# Check every hour
0 * * * * ~/disk-space-monitor/monitor.sh
```

## Manual Investigation

```bash
# Real-time space changes
tail -f ~/.disk_monitor_logs/emergency.log

# Full history
cat ~/.disk_monitor_logs/disk_space.log

# Process records
tail -20 ~/.disk_monitor_logs/disk_writers.log

# Large files
cat ~/.disk_monitor_logs/large_files.log

# Current disk status
df -h /

# Interactive directory scan (requires ncdu)
ncdu ~/
```

## Auto-start on Login

### Method 1: LaunchAgent

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
        <string>/Users/YOUR_USERNAME/disk-space-monitor/statusbar_app.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
PLIST

# Load
launchctl load ~/Library/LaunchAgents/com.diskmonitor.statusbar.plist
```

Replace `/Users/YOUR_USERNAME/` with your actual path!

### Method 2: System Settings

1. Open System Settings
2. General → Login Items
3. Click + to add
4. Select `~/disk-space-monitor/statusbar_app.py`

## Requirements

- macOS 10.13+
- Python 3.7+
- Bash
- sudo privileges (for real-time monitoring)

## Optional Dependencies

```bash
# Interactive disk usage analyzer
brew install ncdu

# Modern disk usage analyzer
brew install dust
```

## Configuration

Customize via environment variables:

```bash
# Custom log directory
export LOG_DIR="/path/to/logs"

# Custom monitoring interval (seconds)
export INTERVAL=60

# Custom large file threshold
export LARGE_FILE_SIZE=500M

./monitor.sh &
```

## Troubleshooting

### Menu Bar App Won't Start

```bash
# Check dependencies
python3 -c "import rumps"

# If error, reinstall
pip3 install rumps pyobjc
```

### No Icon in Menu Bar

- Check if running: `ps aux | grep statusbar_app`
- Restart: `pkill -f statusbar_app && python3 ~/disk-space-monitor/statusbar_app.py &`

### Monitor Shows Stopped

- Start monitoring: `~/disk-space-monitor/emergency_monitor.sh &`

## Common Space Culprits

Based on analysis, common space consumers:

1. **Xcode Simulators** (~34GB) - `xcrun simctl delete unavailable`
2. **WeChat Cache** (~48GB) - Clean in WeChat settings
3. **Downloads** (~187GB) - Review and delete old files
4. **Homebrew Cache** - `brew cleanup`
5. **Docker** - `docker system prune -a`

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## Author

Wendell-Guan

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

- Built with [rumps](https://github.com/jaredks/rumps) for menu bar app
- Uses native macOS tools (df, fs_usage, ps, etc.)

---

**Tip**: If you find WeChat, Xcode, etc. consuming lots of space:
- Clean WeChat: Settings → General → Storage
- Delete Xcode simulators: `xcrun simctl delete unavailable`
- Clean Homebrew: `brew cleanup`
