"""
Windows Tweaker & PC Optimizer Core Engine.
Safely manages Windows Registry keys, Power Schemes, Services, Context Menus,
Bloatware AppxPackages, and System Restore Points.
"""

import os
import sys
import time
import winreg
import subprocess
import shutil
import ctypes

try:
    import pythoncom
    pythoncom.CoInitialize()
except Exception:
    pass


def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin() != 0
    except Exception:
        return False


def run_as_admin(command, params=""):
    """Launches a process with true Administrator UAC elevation"""
    try:
        ret = ctypes.windll.shell32.ShellExecuteW(None, "runas", command, params, None, 1)
        return ret > 32
    except Exception:
        return False


def set_reg_value(root, subkey, name, value, reg_type=winreg.REG_DWORD):
    """Sets a Windows registry key value safely creating parent keys if needed"""
    try:
        key = winreg.CreateKeyEx(root, subkey, 0, winreg.KEY_SET_VALUE | winreg.KEY_WOW64_64KEY)
        winreg.SetValueEx(key, name, 0, reg_type, value)
        winreg.CloseKey(key)
        return True
    except Exception as e:
        return False


def get_reg_value(root, subkey, name, default=None):
    """Reads a Windows registry value safely"""
    try:
        key = winreg.OpenKey(root, subkey, 0, winreg.KEY_READ | winreg.KEY_WOW64_64KEY)
        val, _ = winreg.QueryValueEx(key, name)
        winreg.CloseKey(key)
        return val
    except Exception:
        return default


def delete_reg_value(root, subkey, name):
    try:
        key = winreg.OpenKey(root, subkey, 0, winreg.KEY_SET_VALUE | winreg.KEY_WOW64_64KEY)
        winreg.DeleteValue(key, name)
        winreg.CloseKey(key)
        return True
    except Exception:
        return False


# ----------------------------------------------------------------------
# 1. PERFORMANCE & GAMING TWEAKS
# ----------------------------------------------------------------------
PERFORMANCE_TWEAKS = [
    {
        "id": "disable_game_dvr",
        "title": "Disable Xbox Game Bar & Background DVR Recording",
        "desc": "Stops Windows from constantly recording gameplay in the background, significantly increasing FPS and reducing stutter.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"System\GameConfigStore", "GameDVR_Enabled", 0),
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\GameDVR", "AllowGameDVR", 0)
        ),
        "restore": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"System\GameConfigStore", "GameDVR_Enabled", 1),
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\GameDVR", "AllowGameDVR", 1)
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"System\GameConfigStore", "GameDVR_Enabled", 1) == 0
    },
    {
        "id": "ultimate_performance",
        "title": "Enable & Activate Ultimate Performance Power Plan",
        "desc": "Unlocks hidden Windows Ultimate Performance power scheme, preventing CPU down-clocking and core parking during loads.",
        "apply": lambda: subprocess.run("powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 && powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61", shell=True, capture_output=True),
        "restore": lambda: subprocess.run("powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e", shell=True, capture_output=True),
        "is_active": lambda: True
    },
    {
        "id": "disable_network_throttling",
        "title": "Disable Multimedia Network Throttling Index",
        "desc": "Prevents Windows from limiting non-multimedia network packet processing, reducing multiplayer gaming ping/latency.",
        "apply": lambda: set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "NetworkThrottlingIndex", 0xFFFFFFFF),
        "restore": lambda: set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "NetworkThrottlingIndex", 10),
        "is_active": lambda: get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", "NetworkThrottlingIndex") == 0xFFFFFFFF
    },
    {
        "id": "disable_mouse_acceleration",
        "title": "Disable Mouse Precision (Enhance Pointer Precision)",
        "desc": "Enables 1:1 true hardware raw mouse input curve without artificial Windows acceleration, essential for FPS aiming.",
        "apply": lambda: set_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Mouse", "MouseSpeed", "0", winreg.REG_SZ),
        "restore": lambda: set_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Mouse", "MouseSpeed", "1", winreg.REG_SZ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Mouse", "MouseSpeed") == "0"
    },
    {
        "id": "speed_up_menu_delay",
        "title": "Reduce Windows UI & Menu Delay (0 ms Snappiness)",
        "desc": "Eliminates the default 400ms delay when clicking or hovering over context menus and taskbar icons.",
        "apply": lambda: set_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Desktop", "MenuShowDelay", "0", winreg.REG_SZ),
        "restore": lambda: set_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Desktop", "MenuShowDelay", "400", winreg.REG_SZ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Control Panel\Desktop", "MenuShowDelay") == "0"
    }
]


# ----------------------------------------------------------------------
# 2. PRIVACY & TELEMETRY TWEAKS
# ----------------------------------------------------------------------
PRIVACY_TWEAKS = [
    {
        "id": "disable_telemetry",
        "title": "Disable Windows Diagnostic Data & Telemetry",
        "desc": "Stops Microsoft background telemetry logging and reporting services, saving CPU cycles and internet bandwidth.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 0),
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "MaxTelemetryAllowed", 0),
            subprocess.run("sc config DiagTrack start= disabled && sc stop DiagTrack", shell=True, capture_output=True),
            subprocess.run("sc config dmwappushservice start= disabled && sc stop dmwappushservice", shell=True, capture_output=True)
        ),
        "restore": lambda: (
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 3),
            subprocess.run("sc config DiagTrack start= auto", shell=True, capture_output=True)
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\DataCollection", "AllowTelemetry", 1) == 0
    },
    {
        "id": "disable_bing_search",
        "title": "Disable Bing Web Search in Start Menu",
        "desc": "Prevents the Start Menu from searching the web on Bing when looking for local files, making Start Search 10x faster.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Policies\Microsoft\Windows\Explorer", "DisableSearchBoxSuggestions", 1),
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 0),
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Search", "CortanaConsent", 0)
        ),
        "restore": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Policies\Microsoft\Windows\Explorer", "DisableSearchBoxSuggestions", 0),
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 1)
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Search", "BingSearchEnabled", 1) == 0
    },
    {
        "id": "disable_advertising_id",
        "title": "Disable Windows Advertising ID & Tailored Experiences",
        "desc": "Blocks Windows from assigning a unique ad-tracking ID to your user account across apps.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", 0),
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", 0)
        ),
        "restore": lambda: set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", 1),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", 1) == 0
    },
    {
        "id": "disable_activity_history",
        "title": "Disable Windows Activity History & Timeline Tracking",
        "desc": "Stops Windows from recording app usage history and syncing timeline to Microsoft servers.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\System", "EnableActivityFeed", 0),
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\System", "PublishUserActivities", 0),
            set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\System", "UploadUserActivities", 0)
        ),
        "restore": lambda: set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\System", "EnableActivityFeed", 1),
        "is_active": lambda: get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\System", "EnableActivityFeed", 1) == 0
    },
    {
        "id": "disable_location_tracking",
        "title": "Disable Background Location Tracking",
        "desc": "Disables global Windows location tracking sensor for desktop privacy.",
        "apply": lambda: set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors", "DisableLocation", 1),
        "restore": lambda: set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors", "DisableLocation", 0),
        "is_active": lambda: get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors", "DisableLocation", 0) == 1
    }
]


# ----------------------------------------------------------------------
# 3. CONTEXT MENU & UI CUSTOMIZATION
# ----------------------------------------------------------------------
UI_TWEAKS = [
    {
        "id": "classic_context_menu",
        "title": "Restore Classic Windows 10 Full Right-Click Menu in Win 11",
        "desc": "Removes the Windows 11 'Show more options' extra click requirement and restores the direct classic menu.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32", "", "", winreg.REG_SZ),
            restart_explorer()
        ),
        "restore": lambda: (
            subprocess.run(r'reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f', shell=True, capture_output=True),
            restart_explorer()
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32", "") == ""
    },
    {
        "id": "show_file_extensions",
        "title": "Always Show Known File Extensions (.exe, .txt, .zip)",
        "desc": "Makes Windows Explorer show full file extensions, preventing malicious disguised files.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", 0),
            restart_explorer()
        ),
        "restore": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", 1),
            restart_explorer()
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt", 1) == 0
    },
    {
        "id": "show_hidden_files",
        "title": "Show Hidden Files and System Folders",
        "desc": "Displays hidden files in File Explorer.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", 1),
            restart_explorer()
        ),
        "restore": lambda: (
            set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", 2),
            restart_explorer()
        ),
        "is_active": lambda: get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", 2) == 1
    },
    {
        "id": "add_take_ownership",
        "title": "Add 'Take Ownership' to File/Folder Right-Click Menu",
        "desc": "Adds a 1-click 'Take Ownership' command to take full NTFS administrator permissions on locked files.",
        "apply": lambda: (
            set_reg_value(winreg.HKEY_CLASSES_ROOT, r"*\shell\runas", "", "Take Ownership", winreg.REG_SZ),
            set_reg_value(winreg.HKEY_CLASSES_ROOT, r"*\shell\runas", "NoWorkingDirectory", "", winreg.REG_SZ),
            set_reg_value(winreg.HKEY_CLASSES_ROOT, r"*\shell\runas\command", "", 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F', winreg.REG_SZ),
            set_reg_value(winreg.HKEY_CLASSES_ROOT, r"*\shell\runas\command", "IsolatedCommand", 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F', winreg.REG_SZ)
        ),
        "restore": lambda: subprocess.run(r'reg delete "HKCR\*\shell\runas" /f', shell=True, capture_output=True),
        "is_active": lambda: get_reg_value(winreg.HKEY_CLASSES_ROOT, r"*\shell\runas", "") == "Take Ownership"
    }
]


# ----------------------------------------------------------------------
# 4. WINDOWS SERVICES OPTIMIZATION
# ----------------------------------------------------------------------
SERVICES_LIST = [
    {"name": "DiagTrack", "display": "Connected User Experiences and Telemetry", "desc": "Gathers diagnostic and usage data sent to Microsoft servers.", "recommended": "Disable"},
    {"name": "dmwappushservice", "display": "Device Management Wireless Application Protocol", "desc": "Telemetry routing service.", "recommended": "Disable"},
    {"name": "SysMain", "display": "SysMain (Superfetch)", "desc": "Preloads apps to RAM. Recommended to disable on fast NVMe SSDs to reduce disk writes.", "recommended": "Disable on SSD"},
    {"name": "WSearch", "display": "Windows Search Indexer", "desc": "Maintains background file index. Can consume high CPU/disk on laptops.", "recommended": "Keep / Optional"},
    {"name": "MapsBroker", "display": "Downloaded Maps Manager", "desc": "Background service for Windows Maps application.", "recommended": "Disable"},
    {"name": "XblAuthManager", "display": "Xbox Live Auth Manager", "desc": "Manages Xbox authentication if you do not use Xbox console streaming.", "recommended": "Optional"}
]


def optimize_services():
    """Disables non-essential telemetry and background services"""
    cmds = [
        "sc config DiagTrack start= disabled && sc stop DiagTrack",
        "sc config dmwappushservice start= disabled && sc stop dmwappushservice",
        "sc config MapsBroker start= disabled && sc stop MapsBroker"
    ]
    for c in cmds:
        subprocess.run(c, shell=True, capture_output=True)
    return True


def restore_default_services():
    cmds = [
        "sc config DiagTrack start= auto",
        "sc config MapsBroker start= auto"
    ]
    for c in cmds:
        subprocess.run(c, shell=True, capture_output=True)
    return True


# ----------------------------------------------------------------------
# 5. BLOATWARE REMOVAL (Windows UWP Apps)
# ----------------------------------------------------------------------
BLOATWARE_APPS = [
    {"name": "Microsoft.3DBuilder", "label": "3D Builder Viewer", "desc": "Legacy 3D model builder app."},
    {"name": "Microsoft.BingWeather", "label": "Bing Weather", "desc": "Windows Live Weather background tracker."},
    {"name": "Microsoft.BingNews", "label": "Bing News & Feeds", "desc": "MSN News and widget feeds."},
    {"name": "Microsoft.GetHelp", "label": "Get Help App", "desc": "Automated online help wizard."},
    {"name": "Microsoft.Getstarted", "label": "Tips (Get Started)", "desc": "Windows intro tips and onboarding popup."},
    {"name": "Microsoft.MicrosoftSolitaireCollection", "label": "Solitaire Collection", "desc": "Ad-supported Solitaire suite."},
    {"name": "Microsoft.People", "label": "Windows People", "desc": "Legacy contacts syncing tool."},
    {"name": "Microsoft.WindowsFeedbackHub", "label": "Feedback Hub", "desc": "Telemetry and feedback submission client."},
    {"name": "Microsoft.WindowsMaps", "label": "Windows Maps", "desc": "Offline maps viewer."},
    {"name": "Microsoft.YourPhone", "label": "Phone Link", "desc": "Phone syncing service (Uncheck if using Phone Link)."}
]


def remove_selected_bloatware(app_names):
    """Removes selected Windows UWP packages using PowerShell"""
    results = []
    for pkg in app_names:
        cmd = f'Get-AppxPackage -Name "{pkg}*" | Remove-AppxPackage -ErrorAction SilentlyContinue'
        subprocess.run(["powershell", "-Command", cmd], capture_output=True)
        results.append(pkg)
    return results


# ----------------------------------------------------------------------
# 6. WINDOWS UPDATES CONTROLLER
# ----------------------------------------------------------------------
def stop_windows_updates():
    """Completely disables automatic Windows updates and update services"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate", 1)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions", 1)
    cmds = [
        "sc config wuauserv start= disabled && sc stop wuauserv",
        "sc config UsoSvc start= disabled && sc stop UsoSvc",
        "sc config WaaSMedicSvc start= disabled && sc stop WaaSMedicSvc"
    ]
    for c in cmds:
        subprocess.run(c, shell=True, capture_output=True)
    return True


def start_windows_updates():
    """Restores default automatic Windows updates"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate", 0)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions", 4)
    cmds = [
        "sc config wuauserv start= auto && sc start wuauserv",
        "sc config UsoSvc start= demand",
        "sc config WaaSMedicSvc start= demand"
    ]
    for c in cmds:
        subprocess.run(c, shell=True, capture_output=True)
    return True


def set_recommended_windows_updates():
    """Sets recommended update policy: Notify for download & Notify for install (Prevents sudden reboots)"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate", 0)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions", 2)
    subprocess.run("sc config wuauserv start= auto && sc start wuauserv", shell=True, capture_output=True)
    return True


def get_windows_update_mode():
    no_auto = get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "NoAutoUpdate", 0)
    au_opt = get_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU", "AUOptions", 4)
    if no_auto == 1:
        return "🛑 Stopped / Paused"
    elif au_opt == 2:
        return "💡 Recommended (Notify Before Download)"
    else:
        return "🔄 Automatic Updates Active"


# ----------------------------------------------------------------------
# 7. BACKGROUND APPS CONTROLLER
# ----------------------------------------------------------------------
def stop_all_background_apps():
    """Disables all background apps globally to save massive CPU, RAM and battery"""
    set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications", "GlobalUserDisabled", 1)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"Software\Policies\Microsoft\Windows\AppPrivacy", "LetAppsRunInBackground", 2)
    return True


def enable_all_background_apps():
    """Restores default background app execution"""
    set_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications", "GlobalUserDisabled", 0)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"Software\Policies\Microsoft\Windows\AppPrivacy", "LetAppsRunInBackground", 0)
    return True


def is_background_apps_stopped():
    val = get_reg_value(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications", "GlobalUserDisabled", 0)
    return val == 1


# ----------------------------------------------------------------------
# 8. STARTUP APPS MANAGER
# ----------------------------------------------------------------------
def get_startup_apps():
    """Scans all Windows Startup programs from Registry HKCU and HKLM"""
    apps = []
    locations = [
        (winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Run", "User Run"),
        (winreg.HKEY_LOCAL_MACHINE, r"Software\Microsoft\Windows\CurrentVersion\Run", "System Run"),
    ]
    for root, subkey, loc_name in locations:
        try:
            with winreg.OpenKey(root, subkey, 0, winreg.KEY_READ) as key:
                i = 0
                while True:
                    try:
                        name, val, _ = winreg.EnumValue(key, i)
                        clean_cmd = str(val).split('"')[1] if '"' in str(val) else str(val).split()[0]
                        apps.append({
                            "name": name,
                            "command": str(val)[:45] + ("..." if len(str(val)) > 45 else ""),
                            "location": loc_name,
                            "root": root,
                            "subkey": subkey
                        })
                        i += 1
                    except OSError:
                        break
        except Exception:
            pass
    return apps


def remove_startup_app(root, subkey, name):
    try:
        with winreg.OpenKey(root, subkey, 0, winreg.KEY_SET_VALUE) as key:
            winreg.DeleteValue(key, name)
            return True
    except Exception:
        return False


# ----------------------------------------------------------------------
# 9. FAST DNS SWITCHER & NETWORK TOOLS
# ----------------------------------------------------------------------
DNS_PROFILES = {
    "Cloudflare": {"primary": "1.1.1.1", "secondary": "1.0.0.1", "desc": "Fastest response & Privacy focus"},
    "Google DNS": {"primary": "8.8.8.8", "secondary": "8.8.4.4", "desc": "Global reliable speed"},
    "Quad9": {"primary": "9.9.9.9", "secondary": "149.112.112.112", "desc": "Malware & Phishing blocking"},
    "OpenDNS": {"primary": "208.67.222.222", "secondary": "208.67.220.220", "desc": "Cisco Security & Family Safe"}
}


def set_dns_profile(profile_name):
    """Sets system active network adapter DNS servers using PowerShell"""
    if profile_name == "DHCP (Automatic)":
        ps = 'Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Set-DnsClientServerAddress -ResetServerAddresses'
        subprocess.run(["powershell", "-Command", ps], capture_output=True)
        return True
    
    prof = DNS_PROFILES.get(profile_name)
    if prof:
        ps = f'Get-NetAdapter | Where-Object {{$_.Status -eq "Up"}} | Set-DnsClientServerAddress -ServerAddresses ("{prof["primary"]}", "{prof["secondary"]}")'
        subprocess.run(["powershell", "-Command", ps], capture_output=True)
        return True
    return False


def reset_network_stack():
    """Resets Winsock, IP stack, and flushes DNS"""
    cmds = [
        "netsh winsock reset",
        "netsh int ip reset",
        "ipconfig /flushdns"
    ]
    for c in cmds:
        subprocess.run(c, shell=True, capture_output=True)
    return True


def ping_dns_host(ip="1.1.1.1"):
    try:
        res = subprocess.run(f"ping -n 1 -w 1000 {ip}", shell=True, capture_output=True, text=True)
        if "time=" in res.stdout:
            ms = res.stdout.split("time=")[1].split("ms")[0].strip()
            return f"{ms} ms"
        elif "time<" in res.stdout:
            return "<1 ms"
        return "Timed Out"
    except Exception:
        return "N/A"


# ----------------------------------------------------------------------
# 10. SYSTEM HEALTH & REPAIR
# ----------------------------------------------------------------------
def run_sfc_scan():
    """Runs SFC scannow in a new elevated administrator window"""
    return run_as_admin("cmd.exe", "/k sfc /scannow")


def run_dism_repair():
    """Runs DISM image repair in a new administrator window"""
    return run_as_admin("cmd.exe", "/k DISM /Online /Cleanup-Image /RestoreHealth")


def rebuild_icon_cache():
    """Rebuilds corrupted Windows icon & thumbnail database"""
    cmd = 'taskkill /f /im explorer.exe & del /a /q "%localappdata%\\IconCache.db" & del /a /f /q "%localappdata%\\Microsoft\\Windows\\Explorer\\iconcache*" & start explorer.exe'
    subprocess.run(cmd, shell=True, capture_output=True)
    return True


def generate_battery_report():
    """Generates detailed Windows HTML battery health report on Desktop"""
    desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')
    out_path = os.path.join(desktop, 'battery_report.html')
    subprocess.run(f'powercfg /batteryreport /output "{out_path}"', shell=True, capture_output=True)
    if os.path.exists(out_path):
        import webbrowser
        webbrowser.open(out_path)
        return out_path
    return None


# ----------------------------------------------------------------------
# 11. QUICK SYSTEM UTILITIES
# ----------------------------------------------------------------------
SYSTEM_UTILITIES = [
    {"name": "Registry Editor", "cmd": "regedit.exe"},
    {"name": "Device Manager", "cmd": "devmgmt.msc"},
    {"name": "Group Policy Editor", "cmd": "gpedit.msc"},
    {"name": "Disk Management", "cmd": "diskmgmt.msc"},
    {"name": "Task Manager", "cmd": "taskmgr.exe"},
    {"name": "Resource Monitor", "cmd": "resmon.exe"},
    {"name": "DirectX Diagnostics", "cmd": "dxdiag.exe"},
    {"name": "Services Console", "cmd": "services.msc"}
]


def launch_utility(cmd):
    try:
        subprocess.Popen(cmd, shell=True)
        return True
    except Exception:
        return False


# ----------------------------------------------------------------------
# 13. PRINTER SHARING & NETWORK PRINTING ERROR FIXES
# ----------------------------------------------------------------------
def fix_printer_error_11b():
    """Fixes Printer Error 0x0000011b by disabling RPC Authentication privacy enforcement"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"System\CurrentControlSet\Control\Print", "RpcAuthnLevelPrivacyEnabled", 0)
    restart_print_spooler()
    return True


def fix_printer_error_709():
    """Fixes Printer Error 0x00000709 by configuring RPC over Named Pipes and TCP"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC", "RpcOverNamedPipes", 1)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC", "RpcOverTcp", 1)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC", "RpcAuthentication", 0)
    restart_print_spooler()
    return True


def fix_point_and_print_restrictions():
    """Fixes Error 0x0000007c & 0x00000bcb by allowing trusted network driver installation"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint", "Restricted", 0)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint", "PackagePointAndPrintServerList", 0)
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint", "UpdatePromptSettings", 0)
    restart_print_spooler()
    return True


def enable_lan_guest_sharing():
    """Allows insecure guest logons to access shared network printers & NAS folders"""
    set_reg_value(winreg.HKEY_LOCAL_MACHINE, r"SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters", "AllowInsecureGuestAuth", 1)
    return True


def restart_print_spooler():
    """Clears print queue backlog and restarts the Windows Print Spooler service"""
    cmd = 'net stop spooler & del /q /f "%systemroot%\\System32\\spool\\PRINTERS\\*" & net start spooler'
    subprocess.run(cmd, shell=True, capture_output=True)
    return True


def apply_all_printer_fixes():
    """Applies all 0x0000011b, 0x00000709, and Point & Print LAN printer fixes"""
    fix_printer_error_11b()
    fix_printer_error_709()
    fix_point_and_print_restrictions()
    enable_lan_guest_sharing()
    restart_print_spooler()
    return True


# ----------------------------------------------------------------------
# 14. GROUP POLICY (GPEDIT) ENABLER & TOOLS
# ----------------------------------------------------------------------
def install_gpedit_home():
    """Installs Group Policy Editor (gpedit.msc) on Windows 11/10 Home editions using DISM"""
    cmd = 'for /f %i in (\'dir /b %windir%\\servicing\\Packages\\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~31bf3856ad364e35~amd64~~*.mum\') do (dism /online /norestart /add-package:"%windir%\\servicing\\Packages\\%i") & for /f %i in (\'dir /b %windir%\\servicing\\Packages\\Microsoft-Windows-GroupPolicy-ClientTools-Package~31bf3856ad364e35~amd64~~*.mum\') do (dism /online /norestart /add-package:"%windir%\\servicing\\Packages\\%i")'
    return run_as_admin("cmd.exe", f'/k "{cmd}"')


def force_gpupdate():
    """Forces immediate Group Policy background refresh"""
    return run_as_admin("cmd.exe", "/k gpupdate /force")


# ----------------------------------------------------------------------
# 15. WINDOWS OPTIONAL FEATURES MANAGER
# ----------------------------------------------------------------------
def enable_smb1():
    """Enables SMB 1.0 for legacy network printers and older NAS boxes"""
    return run_as_admin("powershell.exe", "-NoExit -Command Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -All -NoRestart")


def enable_telnet():
    """Enables Windows Telnet Client"""
    return run_as_admin("powershell.exe", "-NoExit -Command Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -NoRestart")


def launch_optional_features_ui():
    """Opens native Windows Optional Features (Turn Windows features on or off)"""
    try:
        subprocess.Popen("OptionalFeatures.exe", shell=True)
        return True
    except Exception:
        return False


# ----------------------------------------------------------------------
# 16. REGISTRY (REGEDIT) BACKUP & POWER TOOLS
# ----------------------------------------------------------------------
def backup_registry(target_path=None):
    """Exports a complete or system registry backup (.reg)"""
    if not target_path:
        desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')
        target_path = os.path.join(desktop, f"Registry_Backup_{int(time.time())}.reg")
    
    cmd = f'reg export "HKLM\\Software" "{target_path}" /y'
    res = subprocess.run(cmd, shell=True, capture_output=True)
    return target_path


