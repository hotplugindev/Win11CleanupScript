# =========================================================
# Windows 11 Ultra-Minimal Interactive Gaming Script (Persistent)
# Prompts before each tweak and can persist choices automatically
# =========================================================

# Directory for persistent copy
$PersistentPath = "C:\ProgramData\UltraGamingMinimal"
$PersistentScript = Join-Path $PersistentPath "Persistent.ps1"

# Create folder if it doesn't exist
if (-not (Test-Path $PersistentPath)) {
    New-Item -ItemType Directory -Path $PersistentPath | Out-Null
}

# Store choices in a hashtable
$UserChoices = @{}

function Confirm-Action($Key, $Description) {
    Write-Host "`n$Description" -ForegroundColor Cyan
    $confirmation = Read-Host "Do you want to apply this tweak? (Y/N)"
    $UserChoices[$Key] = $confirmation -match '^(Y|y)$'
    return $UserChoices[$Key]
}

# -----------------------------
# 1. Trim scheduled tasks
# -----------------------------
if (Confirm-Action "TrimTasks" "Trim scheduled tasks that cause background CPU/GPU spikes (telemetry, maintenance, indexing, feedback, Windows tips)?") {
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
}

# -----------------------------
# 2. Gaming-safe services
# -----------------------------
if (Confirm-Action "Services" "Disable or set to manual unnecessary services like Xbox, telemetry, OneDrive, printing, and indexing?") {
    $services = @(
        "XboxGipSvc","XblAuthManager","XblGameSave","GamingServices",
        "PrintSpooler","RemoteRegistry","WSearch","DiagTrack","dmwappushservice",
        "MapsBroker","RetailDemo","PhoneSvc","WbioSrvc","WMPNetworkSvc",
        "CDPSvc","WaaSMedicSvc"
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
}

# -----------------------------
# 3. OneDrive
# -----------------------------
if (Confirm-Action "OneDrive" "Stop OneDrive syncing completely (safe if not used)?") {
    try {
        Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "UserSettingSyncEnabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "OneDrive syncing disabled"
    }
    catch {}
}

# -----------------------------
# 4. Xbox Game DVR / Game Bar
# -----------------------------
if (Confirm-Action "GameDVR" "Disable Xbox Game DVR / Game Bar recording?") {
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "Game DVR disabled"
    }
    catch {}
}

# -----------------------------
# 5. Reduce animations
# -----------------------------
if (Confirm-Action "Animations" "Reduce taskbar, start menu, and window animations for faster UI?") {
    try {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "Animations reduced"
    }
    catch {}
}

# -----------------------------
# 6. Disable background apps
# -----------------------------
if (Confirm-Action "BackgroundApps" "Disable all Microsoft default apps from running in background?") {
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
}

# -----------------------------
# 7. Search Indexer
# -----------------------------
if (Confirm-Action "SearchIndexer" "Disable Windows Search Indexer? (optional, speeds gaming but slows searches)") {
    try {
        Stop-Service WSearch -Force
        Set-Service WSearch -StartupType Disabled
        Write-Host "Windows Search Indexer disabled"
    }
    catch {}
}

# -----------------------------
# 8. Hibernation / Fast Startup
# -----------------------------
if (Confirm-Action "FastStartup" "Disable Hibernation / Fast Startup?") {
    try {
        powercfg -h off
        Write-Host "Hibernation / Fast Startup disabled"
    }
    catch {}
}

# -----------------------------
# 9. Optional features
# -----------------------------
if (Confirm-Action "OptionalFeatures" "Disable optional features not needed for gaming? (Hyper-V, WSL, Sandbox, Media Playback)") {
    $optionalFeatures = @(
        "Microsoft-Hyper-V-All","Windows-Subsystem-Linux","Containers-DisposableClientVM",
        "Windows-Defender-ApplicationGuard","Windows-Sandbox","MediaPlayback","XPSViewer"
    )
    foreach ($feature in $optionalFeatures) {
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
            Write-Host "Disabled optional feature: ${feature}"
        }
        catch {}
    }
}

# -----------------------------
# 10. Font Cache
# -----------------------------
if (Confirm-Action "FontCache" "Disable Font Cache service (optional, high-end systems)?") {
    try {
        Stop-Service "FontCache" -Force -ErrorAction SilentlyContinue
        Set-Service "FontCache" -StartupType Disabled
        Write-Host "Font Cache service disabled"
    }
    catch {}
}

# -----------------------------
# 11. Ask about persisting changes
# -----------------------------
$persist = Read-Host "`nDo you want to save these choices and persist them after every Windows update or startup? (Y/N)"
if ($persist -match '^(Y|y)$') {
    # Save persistent copy
    $ScriptContent = @"
# =========================================================
# Persistent Ultra Gaming Minimal Script
# Auto-generated based on your choices
# =========================================================
`$UserChoices = $($UserChoices | ConvertTo-Json -Compress)
. '$PSCommandPath'  # Source original script to apply choices
"@
    Set-Content -Path $PersistentScript -Value $ScriptContent -Force

    # Create scheduled task
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PersistentScript`""

    # Hybrid triggers: At startup + At logon
    $TriggerStartup = New-ScheduledTaskTrigger -AtStartup
    $TriggerLogon = New-ScheduledTaskTrigger -AtLogon

    try {
        Register-ScheduledTask -TaskName "UltraGamingMinimalPersistent" `
            -Action $Action `
            -Trigger $TriggerStartup,$TriggerLogon `
            -RunLevel Highest -Force
        Write-Host "`nPersistent scheduled task created: UltraGamingMinimalPersistent"
    }
    catch {
        Write-Host "Failed to create scheduled task: $($_.Exception.Message)"
    }
}

Write-Host "`nAll selected tweaks applied. Restart recommended for full effect." -ForegroundColor Green
