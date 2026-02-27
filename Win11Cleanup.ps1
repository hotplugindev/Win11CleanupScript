# ========================================================
# Windows 11 Ultra-Minimal Gaming Optimization Script
# Applies safe but aggressive tweaks for maximum smoothness
# ========================================================

# -----------------------------
# 1. Trim scheduled tasks (telemetry, CEIP, maintenance, tips)
# -----------------------------
$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Defrag\ScheduledDefrag",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
    "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan",
    "\Microsoft\Windows\Feedback Hub\*",
    "\Microsoft\Windows\Maintenance\*",
    "\Microsoft\Windows\Windows Defender\*"
)

foreach ($taskPath in $tasksToDisable) {
    try {
        Disable-ScheduledTask -TaskPath (Split-Path $taskPath) -TaskName (Split-Path $taskPath -Leaf)
        Write-Host "Disabled scheduled task: ${taskPath}"
    }
    catch {
        Write-Host "Failed to disable ${taskPath}: $($_.Exception.Message)"
    }
}

# -----------------------------
# 2. Disable or set gaming-safe services
# -----------------------------
$services = @(
    "XboxGipSvc",
    "XblAuthManager",
    "XblGameSave",
    "GamingServices",
    "PrintSpooler",
    "RemoteRegistry",
    "WSearch",
    "DiagTrack",           # Connected User Experiences & Telemetry
    "dmwappushservice",    # Device Management Wireless Push
    "MapsBroker",          # Maps update service
    "RetailDemo",          # Retail demo
    "PhoneSvc",            # Phone experience
    "WbioSrvc",            # Biometric services
    "WMPNetworkSvc",       # Windows Media Player Network Sharing
    "CDPSvc",              # Connected Devices Platform Service
    "WaaSMedicSvc"         # Windows Update repair service (can leave manual)
)

foreach ($svc in $services) {
    try {
        Set-Service -Name $svc -StartupType Manual
        Stop-Service -Name $svc -Force
        Write-Host "Set ${svc} to Manual and stopped"
    }
    catch {
        Write-Host "Failed ${svc}: $($_.Exception.Message)"
    }
}

# -----------------------------
# 3. Disable OneDrive completely
# -----------------------------
try {
    Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "UserSettingSyncEnabled" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "OneDrive syncing disabled"
}
catch {}

# -----------------------------
# 4. Disable Xbox DVR / Game Bar Recording
# -----------------------------
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "Game DVR / Game Bar disabled"
}
catch {}

# -----------------------------
# 5. Reduce taskbar/start menu and window animations
# -----------------------------
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "Animations reduced"
}
catch {}

# -----------------------------
# 6. Disable Background Apps (all default Microsoft UWP apps)
# -----------------------------
$apps = Get-AppxPackage | Where-Object { $_.Name -like "Microsoft.*" }

foreach ($app in $apps) {
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\$($app.PackageFullName)"
        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
        Set-ItemProperty -Path $regPath -Name "Enabled" -Value 0 -Force
        Write-Host "Disabled background access for ${($app.Name)}"
    }
    catch {}
}

# -----------------------------
# 7. Disable Windows Search Indexer permanently (optional)
# -----------------------------
try {
    Stop-Service WSearch -Force
    Set-Service WSearch -StartupType Disabled
    Write-Host "Windows Search Indexer disabled"
}
catch {}

# -----------------------------
# 8. Disable Hibernation / Fast Startup
# -----------------------------
try {
    powercfg -h off
    Write-Host "Hibernation / Fast Startup disabled"
}
catch {}

# -----------------------------
# 9. Disable optional Windows features (if not used)
# -----------------------------
$optionalFeatures = @(
    "Microsoft-Hyper-V-All",
    "Windows-Subsystem-Linux",
    "Containers-DisposableClientVM",
    "Windows-Defender-ApplicationGuard",
    "Windows-Sandbox",
    "MediaPlayback",
    "XPSViewer"
)

foreach ($feature in $optionalFeatures) {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
        Write-Host "Disabled optional feature: ${feature}"
    }
    catch {}
}

# -----------------------------
# 10. Optional extreme tweaks (high-end systems)
# -----------------------------
# Disable font cache service if not needed
try {
    Stop-Service "FontCache" -Force -ErrorAction SilentlyContinue
    Set-Service "FontCache" -StartupType Disabled
    Write-Host "Font Cache service disabled"
}
catch {}

# -----------------------------
# 11. Finish
# -----------------------------
Write-Host "All ultra-minimal gaming tweaks applied. Restart recommended for full effect."
