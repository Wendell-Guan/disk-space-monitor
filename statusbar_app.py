#!/usr/bin/env python3
"""
Disk Space Monitor - macOS Menu Bar App
Real-time disk usage monitoring with alerts
"""

import rumps
import subprocess
import os
from datetime import datetime

class DiskSpaceMonitorApp(rumps.App):
    def __init__(self):
        # Get icon path
        icon_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "hard_drive_icon.png"
        )

        # Use icon file if exists, otherwise use emoji
        if os.path.exists(icon_path):
            super(DiskSpaceMonitorApp, self).__init__(
                "HDD",
                icon=icon_path,
                template=True,
                quit_button=None
            )
        else:
            super(DiskSpaceMonitorApp, self).__init__("💾", quit_button=None)

        self.log_dir = os.path.expanduser("~/.disk_monitor_logs")
        self.update_menu()
        
    def get_disk_info(self):
        """Get disk usage information"""
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
        """Update menu items"""
        used, avail, percent = self.get_disk_info()

        # Update title (menu bar display) - only show available space if using icon
        if hasattr(self, 'icon') and self.icon:
            self.title = f"{avail}"
        else:
            self.title = f"💾 {avail}"
        
        # Clear existing menu
        self.menu.clear()
        
        # Add disk info
        self.menu.add(rumps.MenuItem(f"Used: {used}", callback=None))
        self.menu.add(rumps.MenuItem(f"Available: {avail}", callback=None))
        self.menu.add(rumps.MenuItem(f"Usage: {percent}", callback=None))
        self.menu.add(rumps.separator)
        
        # Monitor status
        monitor_status = self.check_monitor_status()
        status_icon = "🟢" if monitor_status else "🔴"
        self.menu.add(rumps.MenuItem(f"{status_icon} Monitor: {'Running' if monitor_status else 'Stopped'}", callback=None))
        self.menu.add(rumps.separator)
        
        # Action buttons
        self.menu.add(rumps.MenuItem("📊 View Logs", callback=self.view_logs))
        self.menu.add(rumps.MenuItem("📸 Create Snapshot", callback=self.create_snapshot))
        self.menu.add(rumps.MenuItem("🔍 Open Log Folder", callback=self.open_log_folder))
        self.menu.add(rumps.separator)
        
        # Quick cleanup options
        clean_menu = [
            rumps.MenuItem("Clean Xcode Simulators", callback=self.clean_xcode),
            rumps.MenuItem("Clean Homebrew Cache", callback=self.clean_homebrew),
            rumps.MenuItem("Open Downloads", callback=self.open_downloads),
        ]
        self.menu.add(rumps.MenuItem("🧹 Quick Cleanup", clean_menu))
        
        self.menu.add(rumps.separator)
        self.menu.add(rumps.MenuItem("🔄 Refresh", callback=self.refresh))
        self.menu.add(rumps.MenuItem("❌ Quit", callback=rumps.quit_application))
    
    def check_monitor_status(self):
        """Check if monitor script is running"""
        try:
            result = subprocess.run(
                ['pgrep', '-f', 'emergency_monitor'],
                capture_output=True
            )
            return result.returncode == 0
        except:
            return False
    
    def view_logs(self, _):
        """View monitor logs"""
        log_file = os.path.join(self.log_dir, "emergency.log")
        if os.path.exists(log_file):
            subprocess.run(['open', '-a', 'Console', log_file])
        else:
            rumps.alert("Log file not found", "Please start the monitoring system first")
    
    def create_snapshot(self, _):
        """Create snapshot"""
        script = os.path.expanduser("~/disk-space-monitor/snapshot.sh")
        if os.path.exists(script):
            subprocess.Popen(['open', '-a', 'Terminal', script])
            rumps.notification(
                title="Creating Snapshot",
                subtitle="",
                message="Creating disk space snapshot..."
            )
        else:
            rumps.alert("Script not found", f"Cannot find {script}")
    
    def open_log_folder(self, _):
        """Open log folder"""
        if os.path.exists(self.log_dir):
            subprocess.run(['open', self.log_dir])
        else:
            rumps.alert("Folder not found", f"Cannot find {self.log_dir}")
    
    def clean_xcode(self, _):
        """Clean Xcode simulators"""
        response = rumps.alert(
            "Clean Xcode Simulators",
            "This will delete all unavailable simulators. Continue?",
            ok="Continue",
            cancel="Cancel"
        )
        if response == 1:
            subprocess.Popen([
                'osascript', '-e',
                'tell application "Terminal" to do script "xcrun simctl delete unavailable"'
            ])
    
    def clean_homebrew(self, _):
        """Clean Homebrew cache"""
        response = rumps.alert(
            "Clean Homebrew",
            "This will clean Homebrew cache. Continue?",
            ok="Continue",
            cancel="Cancel"
        )
        if response == 1:
            subprocess.Popen([
                'osascript', '-e',
                'tell application "Terminal" to do script "brew cleanup"'
            ])
    
    def open_downloads(self, _):
        """Open Downloads folder"""
        downloads = os.path.expanduser("~/Downloads")
        subprocess.run(['open', downloads])
    
    def refresh(self, _):
        """Refresh menu"""
        self.update_menu()
        rumps.notification(
            title="Refreshed",
            subtitle="",
            message=f"Available: {self.get_disk_info()[1]}"
        )
    
    @rumps.timer(30)
    def update_timer(self, _):
        """Auto update every 30 seconds"""
        self.update_menu()

if __name__ == "__main__":
    DiskSpaceMonitorApp().run()
