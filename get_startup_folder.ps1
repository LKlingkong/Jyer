# Get the correct Startup folder for the actual logged-in user.
# Fixes the issue where running as Administrator causes
# %APPDATA% to point to the Admin account instead of the real user.

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
    Write-Error "Cannot find profile for user $loggedOnUser : $profilePath"
    exit 1
}

$startupFolder = Join-Path $profilePath 'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'

if (-not (Test-Path $startupFolder)) {
    New-Item -ItemType Directory -Path $startupFolder -Force | Out-Null
}

Write-Output $startupFolder
