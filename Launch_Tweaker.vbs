Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "C:\Users\user\.gemini\antigravity\scratch\windows_tweaker"
WshShell.Run "pythonw.exe app.py", 0, False
