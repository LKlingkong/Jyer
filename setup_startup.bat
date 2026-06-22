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

set "SCRIPT_DIR=%~dp0"
set "VBS_PATH=%SCRIPT_DIR%startup.vbs"
set "SHORTCUT_NAME=静心自律.lnk"

REM 检查VBS脚本是否存在
if not exist "%VBS_PATH%" (
    echo [错误] 找不到 startup.vbs 文件！
    echo 请确保此bat文件与 startup.vbs 在同一目录
    pause
    exit /b 1
)

echo 脚本路径: %VBS_PATH%
echo.

REM 通过辅助脚本获取正确的启动文件夹
REM 无论是否以管理员身份运行，都会定位到当前登录用户的启动文件夹
set "PS1_PATH=%SCRIPT_DIR%get_startup_folder.ps1"

if not exist "%PS1_PATH%" (
    echo [错误] 找不到 get_startup_folder.ps1 辅助脚本！
    pause
    exit /b 1
)

echo 正在识别当前用户...

for /f "delims=" %%i in ('powershell -ExecutionPolicy Bypass -File "%PS1_PATH%"') do set "STARTUP_FOLDER=%%i"

if "%STARTUP_FOLDER%"=="" (
    echo.
    echo [错误] 无法获取启动文件夹路径！
    echo.
    echo 替代方案 — 手动设置（只需3步）：
    echo   1. Win+R 输入 shell:startup 回车
    echo   2. 将 startup.vbs 右键创建快捷方式，放入打开的文件夹
    echo   3. 重启电脑即可生效
    echo.
    pause
    exit /b 1
)

echo 启动文件夹: %STARTUP_FOLDER%
echo.

REM 创建快捷方式
set "SHORTCUT_FULL=%STARTUP_FOLDER%\%SHORTCUT_NAME%"

powershell -ExecutionPolicy Bypass -Command ^
"$ws = New-Object -ComObject WScript.Shell;" ^
"$sc = $ws.CreateShortcut('%SHORTCUT_FULL%');" ^
"$sc.TargetPath = '%VBS_PATH%';" ^
"$sc.WorkingDirectory = '%SCRIPT_DIR%';" ^
"$sc.Description = '静心自律 - 科学行为管理助手';" ^
"$sc.IconLocation = 'shell32.dll,14';" ^
"$sc.Save();" ^
"if (Test-Path '%SHORTCUT_FULL%') { Write-Host 'OK' } else { throw '创建失败' }"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 创建快捷方式失败！
    echo.
    echo 替代方案 — 手动设置：
    echo   1. Win+R 输入 shell:startup 回车
    echo   2. 将 startup.vbs 右键创建快捷方式，放入打开的文件夹
    echo   3. 重启电脑即可生效
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   √ 设置成功！
echo ============================================
echo.
echo 快捷方式已创建: %SHORTCUT_FULL%
echo.
echo 下次开机时，静心自律程序将自动在浏览器中打开。
echo.
echo 如需取消开机自启，删除以下文件即可：
echo   "%SHORTCUT_FULL%"
echo.
pause
