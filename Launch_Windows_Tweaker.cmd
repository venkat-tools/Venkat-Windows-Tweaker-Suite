@echo off
:: ============================================================================
::  Venkat Windows Tweaker Suite - 1-Click Elevated Launcher
:: ============================================================================
title Launching Venkat Windows Tweaker Suite...
cd /d "%~dp0"

:: Request Admin Privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [INFO] Requesting Administrator Privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

:: Run PowerShell Suite
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0WindowsTweaker.ps1"
exit /b
