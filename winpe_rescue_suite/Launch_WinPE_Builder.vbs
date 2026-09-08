Set objShell = CreateObject("Wscript.Shell")
strDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
objShell.Run "powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File """ & strDir & "\WinPE_Builder.ps1""", 0, False
