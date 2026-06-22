# setup_startup.ps1
# 静心自律 - 开机自启动设置（PowerShell 版本）
# 解决了批处理在中文Windows下的编码问题和管理员运行时路径错误问题

Write-Host "============================================"
Write-Host "     静心自律 - 开机自启动设置工具"
Write-Host "============================================"
Write-Host ""
Write-Host '此脚本将为"静心自律"程序创建开机自启动快捷方式'
Write-Host "这样每次打开电脑时，程序会自动启动提醒你"
Write-Host ""

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsPath = Join-Path $scriptDir "startup.vbs"
$shortcutName = "静心自律.lnk"

# 检查VBS脚本是否存在
if (-not (Test-Path $vbsPath)) {
    Write-Host "[错误] 找不到 startup.vbs 文件！" -ForegroundColor Red
    Write-Host "请确保此脚本与 startup.vbs 在同一目录"
    Read-Host "按回车键退出"
    exit 1
}

Write-Host "脚本路径: $vbsPath"
Write-Host ""

# 获取当前登录用户的正确启动文件夹（管理员运行时也不会错）
Write-Host "正在识别当前用户..."

$loggedOnUser = (Get-CimInstance Win32_ComputerSystem).UserName
if ($loggedOnUser -match '\\(.+)$') {
    $loggedOnUser = $matches[1]
}

$sid = $null
try {
    $ntAccount = New-Object System.Security.Principal.NTAccount($loggedOnUser)
    $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
} catch {
    Write-Warning "NTAccount translation failed, trying fallback..."
}

$profilePath = $null
if ($sid) {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
    $profilePath = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).ProfileImagePath
}

if (-not $profilePath) {
    $profilePath = Join-Path 'C:\Users' $loggedOnUser
}

if (-not (Test-Path $profilePath)) {
    Write-Host "[错误] 无法找到用户 $loggedOnUser 的Profile目录: $profilePath" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

$startupFolder = Join-Path $profilePath 'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'

# 确保启动文件夹存在
if (-not (Test-Path $startupFolder)) {
    New-Item -ItemType Directory -Path $startupFolder -Force | Out-Null
}

Write-Host "启动文件夹: $startupFolder"
Write-Host ""

# 创建快捷方式
$shortcutFull = Join-Path $startupFolder $shortcutName

try {
    $ws = New-Object -ComObject WScript.Shell
    $sc = $ws.CreateShortcut($shortcutFull)
    $sc.TargetPath = $vbsPath
    $sc.WorkingDirectory = $scriptDir
    $sc.Description = "静心自律 - 科学行为管理助手"
    $sc.IconLocation = "shell32.dll,14"
    $sc.Save()

    if (-not (Test-Path $shortcutFull)) {
        throw "快捷方式文件未生成"
    }

    Write-Host ""
    Write-Host "============================================"
    Write-Host "  √ 设置成功！"
    Write-Host "============================================"
    Write-Host ""
    Write-Host "快捷方式已创建: $shortcutFull"
    Write-Host ""
    Write-Host "下次开机时，静心自律程序将自动在浏览器中打开。"
    Write-Host ""
    Write-Host "如需取消开机自启，删除以下文件即可："
    Write-Host "  ""$shortcutFull"""
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[错误] 创建快捷方式失败！$_" -ForegroundColor Red
    Write-Host ""
    Write-Host "替代方案 — 手动设置（只需3步）："
    Write-Host "  1. Win+R 输入 shell:startup 回车"
    Write-Host "  2. 将 startup.vbs 右键创建快捷方式，放入打开的文件夹"
    Write-Host "  3. 重启电脑即可生效"
    Write-Host ""
}

Read-Host "按回车键退出"
