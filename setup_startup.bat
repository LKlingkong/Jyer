@echo off
chcp 65001 >nul
title 静心自律 - 开机自启设置

echo ============================================
echo      静心自律 - 开机自启动设置工具
echo ============================================
echo.
echo 此脚本将为"静心自律"程序创建开机自启动快捷方式
echo 这样每次打开电脑时，程序会自动启动提醒你
echo.

set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SCRIPT_DIR=%~dp0"
set "VBS_PATH=%SCRIPT_DIR%startup.vbs"
set "SHORTCUT_NAME=静心自律.lnk"

echo 启动文件夹: %STARTUP_FOLDER%
echo 脚本路径: %VBS_PATH%
echo.

REM 检查VBS脚本是否存在
if not exist "%VBS_PATH%" (
    echo [错误] 找不到 startup.vbs 文件！
    echo 请确保此bat文件与 startup.vbs 在同一目录
    pause
    exit /b 1
)

REM 创建VBS脚本来创建快捷方式
set "CREATE_SHORTCUT=%TEMP%\create_shortcut.vbs"
echo Set WshShell = CreateObject("WScript.Shell") > "%CREATE_SHORTCUT%"
echo Set Shortcut = WshShell.CreateShortcut("%STARTUP_FOLDER%\%SHORTCUT_NAME%") >> "%CREATE_SHORTCUT%"
echo Shortcut.TargetPath = "%VBS_PATH%" >> "%CREATE_SHORTCUT%"
echo Shortcut.WorkingDirectory = "%SCRIPT_DIR%" >> "%CREATE_SHORTCUT%"
echo Shortcut.Description = "静心自律 - 科学行为管理助手" >> "%CREATE_SHORTCUT%"
echo Shortcut.IconLocation = "shell32.dll,14" >> "%CREATE_SHORTCUT%"
echo Shortcut.Save >> "%CREATE_SHORTCUT%"

cscript //nologo "%CREATE_SHORTCUT%"
del "%CREATE_SHORTCUT%"

echo.
echo ============================================
echo   ✓ 设置成功！
echo ============================================
echo.
echo 快捷方式已创建到启动文件夹。
echo 下次开机时，静心自律程序将自动打开。
echo.
echo 如需取消：删除以下文件即可
echo   %STARTUP_FOLDER%\%SHORTCUT_NAME%
echo.
pause
