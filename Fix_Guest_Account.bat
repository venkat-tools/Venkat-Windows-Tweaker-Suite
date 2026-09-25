@echo off
title Windows 11 Guest Account Fixer
color 0b

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ========================================================
    echo   Requesting Administrator Privileges...
    echo ========================================================
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cls
echo ========================================================
echo       VENKAT TWEAKER - WINDOWS 11 GUEST ACCOUNT FIX
echo ========================================================
echo.
echo [1/3] Disabling deprecated Windows 11 built-in Guest account...
net user Guest /active:no >nul 2>&1
echo [OK] Built-in Guest account disabled.
echo.

echo [2/3] Setting up 100%% Working Guest Account (Visitor)...
net user Visitor >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Visitor account already exists, refreshing settings...
    net user Visitor "" /active:yes >nul 2>&1
) else (
    echo [*] Creating new Visitor account...
    net user Visitor "" /add /fullname:"Guest" /comment:"Working Windows 11 Guest Account" >nul 2>&1
)

echo [3/3] Configuring security and permissions...
net localgroup Users Visitor /add >nul 2>&1
wmic useraccount where name='Visitor' set passwordexpires=false >nul 2>&1

echo.
echo ========================================================
echo  [SUCCESS] Working Guest Account is ready!
echo ========================================================
echo.
echo  * Lock Screen / Start Menu Name : Guest
echo  * Password                      : None (Press Enter to log in)
echo  * Account Type                  : Standard Safe User
echo.
echo You can now click on 'Guest' and log in immediately!
echo ========================================================
echo.
pause
