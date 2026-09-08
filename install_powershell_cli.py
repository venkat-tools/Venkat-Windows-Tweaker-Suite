import os
import subprocess

# 1. Create batch launcher scripts in Python Scripts directory (in PATH)
scripts_dir = r"C:\Users\user\AppData\Local\Programs\Python\Python312\Scripts"
app_dir = r"C:\Users\user\.gemini\antigravity\scratch\windows_tweaker"

cmd_content = f"""@echo off
cd /d "{app_dir}"
start "" pythonw app.py
"""

for cmd_name in ["tweaker.cmd", "windows-tweaker.cmd", "wtweaker.cmd", "win-tweaker.cmd"]:
    target_path = os.path.join(scripts_dir, cmd_name)
    try:
        with open(target_path, "w") as f:
            f.write(cmd_content)
        print(f"Created CLI command: {cmd_name} -> {target_path}")
    except Exception as ex:
        print(f"Error creating {cmd_name}: {ex}")

# 2. Add functions to Windows PowerShell Profile
profile_path = os.path.join(os.environ['USERPROFILE'], 'Documents', 'WindowsPowerShell', 'Microsoft.PowerShell_profile.ps1')
os.makedirs(os.path.dirname(profile_path), exist_ok=True)

ps_profile_addition = f"""
# Windows Tweaker PowerShell Integration
function tweaker {{
    Start-Process pythonw -ArgumentList "app.py" -WorkingDirectory "{app_dir}"
}}
function windows-tweaker {{
    Start-Process pythonw -ArgumentList "app.py" -WorkingDirectory "{app_dir}"
}}
function wtweaker {{
    Start-Process pythonw -ArgumentList "app.py" -WorkingDirectory "{app_dir}"
}}
"""

try:
    existing_content = ""
    if os.path.exists(profile_path):
        with open(profile_path, "r", encoding="utf-8") as f:
            existing_content = f.read()
    
    if "function tweaker" not in existing_content:
        with open(profile_path, "a", encoding="utf-8") as f:
            f.write("\n" + ps_profile_addition)
        print(f"Appended tweaker functions to PowerShell Profile: {profile_path}")
    else:
        print("PowerShell Profile already contains tweaker functions.")
except Exception as ex:
    print(f"Profile error: {ex}")

print("CLI and PowerShell integration successfully installed!")
