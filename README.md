# Venkat Ultimate Windows Tweaker, OS Customizer & Master Diagnostic Suite 🚀

[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-0078D6?logo=windows&style=for-the-badge)](https://github.com/venkat-tools/Venkat-Windows-Tweaker-Suite)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%2B%20%7C%207%2B-5391FE?logo=powershell&style=for-the-badge)](https://github.com/venkat-tools/Venkat-Windows-Tweaker-Suite)
[![Executable](https://img.shields.io/badge/Executable-Native%20.EXE%20Included-10B981?style=for-the-badge)](https://github.com/venkat-tools/Venkat-Windows-Tweaker-Suite)
[![Tools](https://img.shields.io/badge/Tools-380%2B%20Utilities-8B5CF6?style=for-the-badge)](https://github.com/venkat-tools/Venkat-Windows-Tweaker-Suite)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

An enterprise-grade, all-in-one **Windows Optimization, Customization, Repair, Emergency Rescue, and Technician Power Suite**. Built natively with modern WPF and PowerShell, featuring colorful modular cards, robust error handling, and zero external runtime dependencies.

---

## ⚡ Quick Launch (1-Line Command)

Open **PowerShell as Administrator** and paste this command:

```powershell
irm https://raw.githubusercontent.com/venkat-tools/Venkat-Windows-Tweaker-Suite/main/WindowsTweaker.ps1 | iex
```

---

## 📦 Offline & Local Execution

If you downloaded or cloned this repository:

1. **Option 1 (Executable Launcher)**: Double-click `WindowsTweaker.exe` (Requests UAC automatically and opens the suite silently).
2. **Option 2 (Batch Script)**: Double-click `Launch_Windows_Tweaker.cmd`.
3. **Option 3 (PowerShell Direct)**:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\WindowsTweaker.ps1
   ```
4. **Desktop Shortcut**: Run `powershell -ExecutionPolicy Bypass -File .\create_shortcut.ps1` to create a shortcut directly on your desktop.

---

## 🌟 Comprehensive 14-Tab Modules Breakdown

```text
 ┌────────────────────────────────────────────────────────────────────────────────────────┐
 │                        VENKAT WINDOWS TWEAKER MASTER SUITE                             │
 ├────────────────┬─────────────────┬─────────────────┬──────────────────┬────────────────┤
 │  1. Passwords  │  2. App Store   │ 3. Features/Fix │ 4. OS Customizer │ 5. Power Tools │
 ├────────────────┼─────────────────┼─────────────────┼──────────────────┼────────────────┤
 │ 6. Super Admin │  7. Gaming Hub  │ 8. Repair Suite │ 9. OS Tweaks     │ 10. Security   │
 ├────────────────┼─────────────────┼─────────────────┼──────────────────┼────────────────┤
 │ 11. Network    │ 12. Activation  │ 13. Data/Driver │ 14. Quick Hub    │                │
 └────────────────┴─────────────────┴─────────────────┴──────────────────┴────────────────┘
```

### 1. 🛡️ User Passwords & Accounts Management Hub
- **Windows 11 / 10 Dedicated Guest Account Manager (One-Click Visitor Access)**:
  - Fixes Microsoft's permanent block on the legacy built-in `Guest` SID in Windows 10/11.
  - 1-Click creates a working, passwordless Visitor account displayed as **`Guest`** on the lock screen and Start menu.
  - Dedicated buttons: **Enable Working Guest Account**, **Disable Guest Account**, and **Check Guest Account Status**.
  - Includes standalone `Fix_Guest_Account.bat` for offline/quick desktop execution.
- **Local Account Controls**: Reset user passwords, blank out passwords, unlock locked accounts, toggle "Password Never Expires", create local admin accounts.
- **Auto-Logon Configurator**: Configure Windows to log on automatically without password prompts on boot.
- **NirSoft Master Suite Integration (200+ Tools)**:
  - 1-Click Launchpad for NirLauncher Suite with direct auto-setup, file unblocking, and direct package execution.
  - Automatic downloaders and helpers for WebBrowserPassView, WirelessKeyView (Wi-Fi Passwords), MailPassView, and PST password recovery.
- **WinPE Offline SAM Integration**: Direct launcher for offline SAM registry password resets on unbootable Windows installations.

### 2. 🏪 1-Click Mega App Store (WinGet Repository)
- **60+ Essential Applications**: Browsers (Chrome, Firefox, Brave, Edge), Dev Tools (VS Code, Git, Python, NodeJS, Docker), Utilities (7-Zip, PowerToys, Rufus, AnyDesk, TeamViewer, RustDesk), Media (VLC, OBS, Spotify, GIMP), Runtimes (DirectX, VC++ Runtimes, .NET).
- **NirSoft Utilities & Sysinternals**: 1-click batch download and launch of Sysinternals Suite, Process Explorer, ProcMon, Autoruns, and TCPView.

### 3. 🧩 Windows Features, Add-ons & Fixes
- **Feature Installer**: Enable/Disable Hyper-V, WSL (Windows Subsystem for Linux), Windows Sandbox, Telnet Client, TFTP, SMB1 (Legacy), DirectPlay, and .NET Framework 3.5.
- **System Add-ons**: Visual C++ AIO Redistributables, DirectX End-User Runtimes, OpenSSH Server setup, and PowerShell 7 installer.

### 4. ⚙️ OS Customizer & Unattended Setup Wizard
- **autounattend.xml Answer File Generator**:
  - Bypass Microsoft Account (MSA) requirement.
  - Bypass Windows 11 TPM 2.0, SecureBoot, RAM, and Storage hardware checks.
  - Auto-create local administrator user accounts with predefined configurations.
- **Live OOBE Bypass**: 1-Click execution of `oobe\bypassnro` for Windows 11 setup network bypass.
- **Official ISO Downloaders**: Quick links and scripts to download genuine Windows 10, 11, and Rufus USB creators.

### 5. ⚡ Advanced Technician Power Tools Hub
- **Quick Toggles**: Windows Defender toggle, Print Spooler restart & queue flush, OneDrive uninstaller/reinstaller, Mobile Hotspot switch, Battery Health report generator (`powercfg /batteryreport`).
- **DoD 3-Pass Secure File Shredder**: Securely wipe confidential files and folders beyond recovery.
- **Driver Store Management**: 1-Click Export & Backup all third-party drivers to USB or local disk (`dism /export-driver`), and Import/Restore drivers.

### 6. 👑 Super Admin & Advanced System Controls
- **Permission Master**: "Take Ownership" context menu injector with full SYSTEM permissions.
- **Hardware & OEM Key Extractor**: Extract embedded BIOS/UEFI Windows OEM product keys and hardware serial numbers with 1-click clipboard copy.
- **GodMode**: Enable the all-in-one Master Control Panel on your desktop.
- **Registry Master Hub**: Quick launch Regedit with predefined key navigations and deep policy tweaks.

### 7. 🎮 Gaming & Hardware Performance
- **Game Mode Optimization**: Enable Hardware-Accelerated GPU Scheduling (HAGS), Game Mode, Ultimate Performance Power Plan.
- **Latency & Responsiveness**: Disable Nagle's Algorithm (`TcpAckFrequency`), reduce mouse/keyboard input lag, disable Xbox Game Bar overlays.
- **Real-Time Diagnostics**: Live CPU, RAM, and GPU status monitors, DirectX Diagnostic Tool (`dxdiag`), and Device Manager.

### 8. 🛠️ Repair & Storage Master Suite
- **System Integrity Scans**: SFC (`sfc /scannow`), DISM Health Check & Component Store Repair (`dism /online /cleanup-image /restorehealth`).
- **Subsystem Fixes**: Windows Update components reset (SoftwareDistribution purge), Core DLL re-registration, Microsoft Store reset (`wsreset.exe`), Winsock reset, Print Spooler repair.
- **Boot & WinRE Repair**: EFI / BCD bootloader repair, Windows Recovery Environment (`reagentc /enable` / `/info`) fixer.
- **Office Quick & Online Repair**: 1-Click Microsoft 365 / Office Click-to-Run repair launcher.
- **Storage & Disk Master**: Master Disk Cleaner (Temp, Prefetch, Log files, Delivery Optimization), Drive Optimization (TRIM & Defrag), MBR to GPT conversion wizard, and Chkdsk scheduler.

### 9. 🎨 OS Tweaks & Customizations
- **Windows Explorer**: Show file extensions, show hidden files, restore Windows 10 classic context menu in Windows 11, disable Search Highlights.
- **Privacy & Telemetry**: Disable Diagnostic Data telemetry, disable Activity History, disable Advertising ID, turn off Cortana.
- **Performance**: Disable startup delays, disable unnecessary animations, boost menu show speed.

### 10. 🔒 Windows Security & Defender Controls
- **Security Centers**: Windows Defender Antivirus toggles, SmartScreen filter settings, Windows Firewall state management, BitLocker Drive Encryption management, and Windows Update pause/resume.

### 11. 🌐 Network & DNS Suite
- **DNS Presets**: Switch DNS with 1-click (Cloudflare `1.1.1.1`, Google `8.8.8.8`, Quad9 `9.9.9.9`, OpenDNS, AdGuard Ad-blocking DNS).
- **Network Troubleshooting**: Flush DNS cache, Reset TCP/IP stack, Release/Renew IP, Network Adapter status viewer, Ping, Traceroute, and Speedtest helper.
- **Hosts File Editor**: Integrated graphical Hosts file editor with instant apply and backup.

### 12. 🔑 Activation & Windows Edition Suite
- **Microsoft Office Click-to-Run (C2R) Installer Hub**:
  - Direct 1-Click official Microsoft setup bootstrapper downloads for **Office 2024**, **Office 2021**, **Office 2019**, and **Microsoft 365**.
  - Smart detection of existing Office installations with 1-click upgrade and activation prompts.
- **Microsoft Activation Scripts (MAS) & Ohook**:
  - Direct Ohook permanent Office activation engine (`mas /Ohook`).
  - HWID permanent Windows activation and KMS38/Online KMS tools.
- **Edition Switcher**: Upgrade from Windows 10/11 Home to Pro / Enterprise without reinstalling.

### 13. 📁 Data & Drivers Hub
- **Robocopy Backup Suite**: High-speed, multi-threaded user data backup and mirror tool.
- **Driver Store Management**: Export all installed drivers to a folder for offline re-installation; Import drivers into offline images or live OS.
- **Storage Space Visualizer**: Quick visual analysis of large files and folders.

### 14. 🧭 Quick Hub & Technician Consoles
- **Direct Management Consoles**: Computer Management (`compmgmt.msc`), Device Manager, Event Viewer, Services (`services.msc`), Disk Management, Group Policy Editor (`gpedit.msc`), Local Security Policy (`secpol.msc`).
- **Technician DevTools**: Direct access to Resource Monitor, Task Manager, PowerShell 7, Command Prompt, System Information (`msinfo32`), and Sysinternals Live.

---

## 🚑 WinPE Emergency Rescue Suite (Hiren's BootCD Alternative)

Located in `winpe_rescue_suite/`:
- **Live & Offline SAM Password Reset**: Unlock accounts and reset admin passwords directly on unbootable Windows partitions.
- **1-Click EFI / BCD Bootloader Rebuilder**: Automatically scan and repair corrupted BCD records (`0xc000000e`, `0xc0000001` BSODs).
- **Sticky Keys CMD Injector**: Replace `sethc.exe` with `cmd.exe` to spawn an elevated SYSTEM Command Prompt on the Windows login screen via 5x `Shift`.
- **Offline Registry Hive Mounter**: Mount unbootable `SYSTEM` & `SOFTWARE` registry hives into Regedit.
- **Offline Data Rescue Wizard**: Robocopy profile extractor to rescue user desktop, documents, and pictures to an external USB drive.
- **1-Click WinPE Bootable USB / ISO Builder**: Build a bootable rescue USB or ISO using local `Winre.wim`.

---

## 🛡️ Safety & Reliability

- **Non-Destructive Defaults**: All optimizations and tweaks are reversible.
- **No Telemetry / No Tracking**: 100% open-source, runs completely locally on your machine.
- **Elevated Privilege Check**: Automatically detects and requests UAC Administrator privileges when required.

---

## 💻 System Requirements

- **Operating System**: Windows 11, Windows 10 (1809+), Windows 8 / 8.1 (85%+ features supported natively), or Windows Server 2012 R2 - 2025.
- **Architecture**: x64, x86, or ARM64.
- **PowerShell**: PowerShell 5.1 (Built into Windows) or PowerShell 7+.

---

## 📜 License & Credits

Distributed under the **MIT License**. Created with ❤️ for Windows Power Users, System Administrators, and IT Technicians.
