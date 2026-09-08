$desktop = [Environment]::GetFolderPath("Desktop")
$psAppPath = "C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\WindowsTweaker.ps1"

# 1. Desktop Batch Launcher for PowerShell Edition
$batPath = "$desktop\Windows-Tweaker-PowerShell.bat"
$batContent = "@echo off`npowershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$psAppPath`""
Set-Content -Path $batPath -Value $batContent -Force

# 2. Add tweaker.ps1 to Python Scripts in PATH
$scriptsDir = "C:\Users\user\AppData\Local\Programs\Python\Python312\Scripts"
$psCliPath = "$scriptsDir\tweaker.ps1"
$psCliContent = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$psAppPath`""
Set-Content -Path $psCliPath -Value $psCliContent -Force

Write-Host "PowerShell Edition Launchers created successfully!"
