# Create Desktop Shortcut for Venkat Windows Tweaker Suite
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $currentDir) { $currentDir = Get-Location }

$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Venkat Windows Tweaker Suite.lnk"
$iconPath = Join-Path $currentDir "tweaker_icon.ico"
$exePath = Join-Path $currentDir "WindowsTweaker.exe"
$ps1Path = Join-Path $currentDir "WindowsTweaker.ps1"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)

if (Test-Path $exePath) {
    $Shortcut.TargetPath = $exePath
    $Shortcut.Arguments = ""
} else {
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$ps1Path`""
}

$Shortcut.WorkingDirectory = $currentDir
if (Test-Path $iconPath) {
    $Shortcut.IconLocation = "$iconPath,0"
}
$Shortcut.Description = "Venkat Windows Tweaker Suite - Ultimate Windows Optimizer & Toolbox"
$Shortcut.Save()

Write-Host "SUCCESS: Desktop shortcut created at $shortcutPath" -ForegroundColor Green
