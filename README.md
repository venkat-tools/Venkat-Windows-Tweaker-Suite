# Venkat Ultimate Windows Tweaker, OS Customizer & WinPE Diagnostic Master Suite 🚀

![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011%20%7C%20Server-0078D6?logo=windows)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%2B%20%7C%207%2B-5391FE?logo=powershell)
![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python)
![Tools](https://img.shields.io/badge/Tools-360%2B%20Utilities-10B981)
![License](https://img.shields.io/badge/License-MIT-blue)

An all-in-one, enterprise-grade **Windows Optimization, Customization, Repair, and Emergency Rescue Suite**. Built natively with WPF & PowerShell along with a cross-platform Python GUI.

---

## 🌟 Key Features & Modules

### 1. 🛡️ User Passwords & Accounts Management Hub
- **Local Account Management**: Reset user passwords, remove passwords (blank login), unlock locked accounts, set passwords to never expire.
- **Auto-Logon Configurator**: Configure automatic logon without password prompt upon Windows boot.
- **NirSoft Master Suite Integration (200+ Tools)**:
  - 1-Click Launchpad for NirLauncher Suite.
  - Automatic downloader & setup helper with extraction guides.
  - WebBrowserPassView, WirelessKeyView (Wi-Fi Passwords), and Outlook PST recovery tools.

### 2. 🚑 Venkat WinPE Emergency Rescue Suite (Hiren's BootCD Alternative)
Located in `winpe_rescue_suite/`:
- **Live & Offline SAM Password Reset**: Unlock accounts and reset admin passwords directly on unbootable Windows drives.
- **1-Click EFI / BCD Bootloader Rebuilder**: Automatically repairs corrupted BCD records (`0xc000000e`, `0xc0000001` BSODs).
- **Sticky Keys CMD Injector**: Swaps `sethc.exe` with `cmd.exe` to allow Administrator command prompt on Windows login screen via 5x `Shift`.
- **Offline Registry Hive Mounter**: Mounts unbootable `SYSTEM` & `SOFTWARE` registry hives into Regedit.
- **Offline Data Rescue Wizard**: Robocopy profile extractor to rescue desktop and user documents to an external USB.
- **1-Click WinPE Bootable USB / ISO Builder Wizard**: Builds custom rescue ISOs from local `Winre.wim` or ISO images.

### 3. 🏪 Mega 1-Click App Store (WinGet Repository)
- Batch installer for over 60+ popular utilities across Microsoft Suite, Web Browsers, Remote Access, Utilities, Development, and Media software.

### 4. ⚙️ OS Customizer & Unattended ISO Setup Builder
- **autounattend.xml Generator**: Creates answer files to bypass Microsoft Account (MSA), bypass TPM 2.0/SecureBoot/RAM checks, and auto-configure local users.
- **Live OOBE Bypass**: Quick bypass for Windows 11 setup network requirement (`oobe\bypassnro`).

### 5. ⚡ Advanced Technician Power Tools & Super Admin
- Windows Defender controls, telemetry purger, GodMode activator, DoD 3-Pass secure file shredder, Wi-Fi hotspot creator, and OEM BIOS product key extractor.

---

## 🚀 Getting Started

### Prerequisites
- Windows 10, 11, or Windows Server.
- PowerShell 5.1 (Built-in) or PowerShell 7+.
- Administrator privileges.

### Launching the Suite

#### Option A: Native PowerShell & WPF (Recommended)
Double-click `Launch_Tweaker.vbs` or run directly in PowerShell:
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\WindowsTweaker.ps1
```

#### Option B: Python GUI
```bash
python -m pip install -r requirements.txt
python app.py
```

---

## 📁 Repository Structure

```text
├── WindowsTweaker.ps1       # Master WPF & PowerShell Tweaker & OS Suite (360+ Tools)
├── Launch_Tweaker.vbs       # 1-Click Silent Launcher
├── app.py                   # Python Tkinter/CustomTkinter GUI
├── cleaner_engine.py        # System Disk & Temp Cleaner Engine
├── tweaks_engine.py         # Performance, Registry & Privacy Tweaks Engine
├── ui_theme.py              # Theme & UI Styling
├── icon_generator.py        # Dynamic App Icon Generator
├── winpe_rescue_suite/      # Standalone WinPE Rescue Master Suite & Builder
│   ├── VenkatRescueSuite.ps1 # Offline SAM Password, BCD & Registry Rescue GUI
│   ├── WinPE_Builder.ps1     # 1-Click Bootable USB / ISO Builder Wizard
│   ├── Launch_Rescue_Suite.vbs
│   └── Launch_WinPE_Builder.vbs
└── README.md
```

---

## 📜 License
Distributed under the MIT License. See `LICENSE` for more information.
