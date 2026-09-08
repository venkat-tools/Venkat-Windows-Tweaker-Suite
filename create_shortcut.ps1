
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut('C:\Users\user\Desktop\Windows-Tweaker.lnk')
$Shortcut.TargetPath = 'C:\Users\user\AppData\Local\Programs\Python\Python312\pythonw.exe'
$Shortcut.Arguments = 'app.py'
$Shortcut.WorkingDirectory = 'C:\Users\user\.gemini\antigravity\scratch\windows_tweaker'
$Shortcut.IconLocation = 'C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\tweaker_icon.ico'
$Shortcut.Description = 'Ultimate Windows Tweaker & PC Optimizer Suite'
$Shortcut.Save()
