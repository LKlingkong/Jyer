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
set "SHORTCUT_FULL=%STARTUP_FOLDER%\%SHORTCUT_NAME%"

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

REM 确保启动文件夹存在
if not exist "%STARTUP_FOLDER%" (
    mkdir "%STARTUP_FOLDER%" 2>nul
)

REM 使用PowerShell创建快捷方式（兼容性更好，处理空格路径更可靠）
powershell -ExecutionPolicy Bypass -Command ^
"$startup = [Environment]::GetEnvironmentVariable('STARTUP_FOLDER','Process');" ^
"$vbs = [Environment]::GetEnvironmentVariable('VBS_PATH','Process');" ^
"$dir = [Environment]::GetEnvironmentVariable('SCRIPT_DIR','Process');" ^
"$name = [Environment]::GetEnvironmentVariable('SHORTCUT_NAME','Process');" ^
"$linkPath = Join-Path $startup $name;" ^
"$ws = New-Object -ComObject WScript.Shell;" ^
"$sc = $ws.CreateShortcut($linkPath);" ^
"$sc.TargetPath = $vbs;" ^
"$sc.WorkingDirectory = $dir;" ^
"$sc.Description = '静心自律 - 科学行为管理助手';" ^
"$sc.IconLocation = 'shell32.dll,14';" ^
"$sc.Save();" ^
"if (Test-Path $linkPath) { Write-Host 'OK' } else { throw 'Failed to create shortcut' }"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 创建快捷方式失败！
    echo 请尝试：右键此文件 → "以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   ✓ 设置成功！
echo ============================================
echo.
echo 快捷方式已创建到启动文件夹。
echo 下次开机时，静心自律程序将自动打开。
echo.
echo 如需取消：删除以下文件即可
echo   %SHORTCUT_FULL%
echo.
pause
