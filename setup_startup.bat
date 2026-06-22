@echo off
REM setup_startup.bat - Launcher for setup_startup.ps1
REM Avoids encoding issues on Chinese Windows by delegating to PowerShell

set "SCRIPT_DIR=%~dp0"
set "PS1_PATH=%SCRIPT_DIR%setup_startup.ps1"

if not exist "%PS1_PATH%" (
    echo [ERROR] setup_startup.ps1 not found.
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -File "%PS1_PATH%"
pause
