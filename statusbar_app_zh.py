#!/usr/bin/env python3
"""
Disk Space Monitor - macOS 状态栏应用
显示实时磁盘使用情况，点击查看详情
"""

import rumps
import subprocess
import os
from datetime import datetime

class DiskSpaceMonitorApp(rumps.App):
    def __init__(self):
        super(DiskSpaceMonitorApp, self).__init__("💾", quit_button=None)
        self.log_dir = os.path.expanduser("~/.disk_monitor_logs")
        self.update_menu()
        
    def get_disk_info(self):
        """获取磁盘使用信息"""
        try:
            result = subprocess.run(
                ['df', '-h', '/'],
                capture_output=True,
                text=True
            )
            lines = result.stdout.strip().split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                used = parts[2]
                avail = parts[3]
                percent = parts[4]
                return used, avail, percent
        except:
            return "N/A", "N/A", "N/A"
    
    def update_menu(self):
        """更新菜单"""
        used, avail, percent = self.get_disk_info()
        
        # 更新标题（状态栏显示）
        self.title = f"💾 {avail}"
        
        # 清空现有菜单
        self.menu.clear()
        
        # 添加磁盘信息
        self.menu.add(rumps.MenuItem(f"已用空间: {used}", callback=None))
        self.menu.add(rumps.MenuItem(f"可用空间: {avail}", callback=None))
        self.menu.add(rumps.MenuItem(f"使用率: {percent}", callback=None))
        self.menu.add(rumps.separator)
        
        # 监控状态
        monitor_status = self.check_monitor_status()
        status_icon = "🟢" if monitor_status else "🔴"
        self.menu.add(rumps.MenuItem(f"{status_icon} 监控状态: {'运行中' if monitor_status else '未运行'}", callback=None))
        self.menu.add(rumps.separator)
        
        # 功能按钮
        self.menu.add(rumps.MenuItem("📊 查看监控日志", callback=self.view_logs))
        self.menu.add(rumps.MenuItem("📸 创建快照", callback=self.create_snapshot))
        self.menu.add(rumps.MenuItem("🔍 打开监控文件夹", callback=self.open_log_folder))
        self.menu.add(rumps.separator)
        
        # 快速清理选项
        clean_menu = [
            rumps.MenuItem("清理 Xcode 模拟器", callback=self.clean_xcode),
            rumps.MenuItem("清理 Homebrew 缓存", callback=self.clean_homebrew),
            rumps.MenuItem("打开下载文件夹", callback=self.open_downloads),
        ]
        self.menu.add(rumps.MenuItem("🧹 快速清理", clean_menu))
        
        self.menu.add(rumps.separator)
        self.menu.add(rumps.MenuItem("🔄 刷新", callback=self.refresh))
        self.menu.add(rumps.MenuItem("❌ 退出", callback=rumps.quit_application))
    
    def check_monitor_status(self):
        """检查监控脚本是否在运行"""
        try:
            result = subprocess.run(
                ['pgrep', '-f', 'emergency_monitor'],
                capture_output=True
            )
            return result.returncode == 0
        except:
            return False
    
    def view_logs(self, _):
        """查看监控日志"""
        log_file = os.path.join(self.log_dir, "emergency.log")
        if os.path.exists(log_file):
            subprocess.run(['open', '-a', 'Console', log_file])
        else:
            rumps.alert("日志文件不存在", "请先启动监控系统")
    
    def create_snapshot(self, _):
        """创建快照"""
        script = os.path.expanduser("~/disk-space-monitor/snapshot.sh")
        if os.path.exists(script):
            subprocess.Popen(['open', '-a', 'Terminal', script])
            rumps.notification(
                title="快照创建中",
                subtitle="",
                message="正在创建磁盘空间快照..."
            )
        else:
            rumps.alert("脚本不存在", f"找不到 {script}")
    
    def open_log_folder(self, _):
        """打开日志文件夹"""
        if os.path.exists(self.log_dir):
            subprocess.run(['open', self.log_dir])
        else:
            rumps.alert("文件夹不存在", f"找不到 {self.log_dir}")
    
    def clean_xcode(self, _):
        """清理 Xcode 模拟器"""
        response = rumps.alert(
            "清理 Xcode 模拟器",
            "这将删除所有不可用的模拟器，继续吗？",
            ok="继续",
            cancel="取消"
        )
        if response == 1:
            subprocess.Popen([
                'osascript', '-e',
                'tell application "Terminal" to do script "xcrun simctl delete unavailable"'
            ])
    
    def clean_homebrew(self, _):
        """清理 Homebrew 缓存"""
        response = rumps.alert(
            "清理 Homebrew",
            "这将清理 Homebrew 缓存，继续吗？",
            ok="继续",
            cancel="取消"
        )
        if response == 1:
            subprocess.Popen([
                'osascript', '-e',
                'tell application "Terminal" to do script "brew cleanup"'
            ])
    
    def open_downloads(self, _):
        """打开下载文件夹"""
        downloads = os.path.expanduser("~/Downloads")
        subprocess.run(['open', downloads])
    
    def refresh(self, _):
        """刷新菜单"""
        self.update_menu()
        rumps.notification(
            title="已刷新",
            subtitle="",
            message=f"可用空间: {self.get_disk_info()[1]}"
        )
    
    @rumps.timer(30)
    def update_timer(self, _):
        """每30秒自动更新"""
        self.update_menu()

if __name__ == "__main__":
    DiskSpaceMonitorApp().run()
