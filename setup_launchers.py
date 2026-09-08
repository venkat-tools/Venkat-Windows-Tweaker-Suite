import os
import subprocess

# 1. Project Launch_Tweaker.vbs
vbs_path = r"C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\Launch_Tweaker.vbs"
with open(vbs_path, "w") as f:
    f.write('Set WshShell = CreateObject("WScript.Shell")\n')
    f.write('WshShell.CurrentDirectory = "C:\\Users\\user\\.gemini\\antigravity\\scratch\\windows_tweaker"\n')
    f.write('WshShell.Run "pythonw.exe app.py", 0, False\n')

# 2. Desktop Windows-Tweaker.bat
desktop = os.path.join(os.environ['USERPROFILE'], 'Desktop')
bat_path = os.path.join(desktop, 'Windows-Tweaker.bat')
with open(bat_path, "w") as f:
    f.write('@echo off\n')
    f.write('cd /d "C:\\Users\\user\\.gemini\\antigravity\\scratch\\windows_tweaker"\n')
    f.write('start "" pythonw app.py\n')

# 3. Desktop Shortcut with Shield Icon
lnk_path = os.path.join(desktop, 'Windows-Tweaker.lnk')
icon_path = r"C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\tweaker_icon.ico"
target = r"C:\Users\user\AppData\Local\Programs\Python\Python312\pythonw.exe"
work_dir = r"C:\Users\user\.gemini\antigravity\scratch\windows_tweaker"

ps_cmd = f"""
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut('{lnk_path}')
$Shortcut.TargetPath = '{target}'
$Shortcut.Arguments = 'app.py'
$Shortcut.WorkingDirectory = '{work_dir}'
$Shortcut.IconLocation = '{icon_path}'
$Shortcut.Description = 'Ultimate Windows Tweaker & PC Optimizer Suite'
$Shortcut.Save()
"""
ps_script_path = r"C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\create_shortcut.ps1"
with open(ps_script_path, "w") as f:
    f.write(ps_cmd)

subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script_path], capture_output=True)
print("Windows Tweaker desktop shortcuts and launchers created successfully!")
