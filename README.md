Ultra Gaming Minimal – Windows 11 Optimization Script
Overview

This script applies ultra-minimal optimizations for Windows 11 aimed at maximizing gaming performance and reducing micro-stutters. It safely disables unnecessary background apps, services, telemetry, animations, indexing, and optional features while keeping your system stable.

It also includes instructions to automatically reapply these optimizations after every Windows update or at user logon.

Features

Trims scheduled tasks that cause background CPU/GPU spikes (telemetry, maintenance, indexing).

Disables Xbox/Game DVR, OneDrive syncing, and Microsoft UWP background apps.

Reduces Windows UI animations for faster window and taskbar performance.

Disables Windows Search Indexer and Hibernation/Fast Startup (optional).

Disables safe services that are unnecessary for gaming.

Disables optional Windows features (Hyper-V, WSL, Windows Sandbox, Media Playback, XPS Viewer).

Provides a fully automated scheduled task to reapply optimizations after updates.

Prerequisites

Windows 11 (should work on Windows 10, but some features may differ).

Administrative privileges to apply system tweaks.

PowerShell Execution Policy must allow running scripts (Bypass recommended).

Step 1: Save the Script

Create a folder for scripts (example: C:\Scripts).

Save the file as:

C:\Scripts\UltraGamingMinimal.ps1
Step 2: Run the Script Manually (First Time)

Open PowerShell as Administrator.

Run:

Set-ExecutionPolicy Bypass -Scope Process
C:\Scripts\UltraGamingMinimal.ps1

Wait for the script to complete.

Restart your PC for full effect.

Step 3: Make It Run Automatically After Every Update

This ensures Windows cannot revert your optimizations after updates.

3.1 Open Task Scheduler

Press Win + S → type Task Scheduler → open it.

Click Create Task (not Basic Task).

3.2 General Tab

Name: UltraGamingMinimalPostUpdate

Check: Run with highest privileges

Option: Run whether user is logged in or not

3.3 Triggers Tab

Trigger 1: After Windows Update

Begin the task: On an event

Log: Microsoft-Windows-WindowsUpdateClient/Operational

Event ID: 19 (successful update)

Trigger 2: At Logon (Optional)

Begin the task: At logon

Ensures tweaks persist if Windows resets some settings after update.

3.4 Actions Tab

Action: Start a program

Program/script: powershell.exe

Add arguments:

-ExecutionPolicy Bypass -File "C:\Scripts\UltraGamingMinimal.ps1"
3.5 Conditions & Settings

Conditions: uncheck “Start the task only if the computer is on AC power” (optional for desktops).

Settings:

Check “Run task as soon as possible after a scheduled start is missed”

Check “If the task fails, restart every 1 minute, attempt 3 times”

Step 4: Verification

After running the script manually or automatically:

Open Task Manager → Services to see disabled services.

Open Settings → Privacy → Background apps to confirm background access is off.

Check scheduled tasks you disabled are no longer running automatically.

Restart your PC to confirm all changes persist.

Step 5: Reverting Changes (Optional)

Restore a system restore point if made prior to running the script.

Services can be set back to Automatic in Task Manager → Services.

Optional features can be re-enabled via PowerShell:

Enable-WindowsOptionalFeature -Online -FeatureName <FeatureName>

Background apps can be re-enabled via Settings → Apps → Apps & Features → Background apps.
