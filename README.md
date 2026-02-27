# **Ultra Gaming Minimal Interactive – Persistent Windows 11 Optimization Script**

## **Overview**

This script is an **interactive Windows 11 optimization tool** designed to maximize gaming performance by safely disabling:

* Background apps, UWP apps, and telemetry
* Scheduled tasks that cause CPU/GPU spikes
* Unnecessary services (Xbox, printing, indexing, OneDrive, telemetry)
* Windows animations and visual effects
* Optional Windows features (Hyper-V, WSL, Sandbox, Media Playback)

It also allows you to **persist your chosen optimizations** automatically after **Windows updates** or at **logon**, so your system remains optimized without manually rerunning the script.

---

## **Features**

* Prompts before every tweak with **clear explanations**
* Records your **choices** for later reuse
* Optionally saves a **persistent script** in a safe location (`C:\ProgramData\UltraGamingMinimal\Persistent.ps1`)
* Automatically creates a **scheduled task** to run the persistent script at **logon** and **after Windows updates**
* Includes extreme tweaks for high-end systems like **Ryzen 5800X + 32GB RAM**

---

## **Prerequisites**

* Windows 11 (Windows 10 partially supported)
* Administrator privileges
* PowerShell execution policy allowing script execution (Bypass recommended)

---

## **Step 1: Save the Script**

1. Create a folder for scripts (e.g., `C:\Scripts`).
2. Save the file as:

```
C:\Scripts\UltraGamingMinimalPersistent.ps1
```

---

## **Step 2: Run the Script**

1. Open **PowerShell as Administrator**
2. Execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
C:\Scripts\UltraGamingMinimalPersistent.ps1
```

3. The script will **prompt for each tweak**:

* You type `Y` to apply or `N` to skip
* Explanations are provided for each tweak so you understand the impact

---

## **Step 3: Persist Your Choices**

At the end, the script will ask:

> “Do you want to save these choices and persist them after every Windows update?”

* **Yes:**

  * Saves a copy of the script with your selected choices in:

  ```
  C:\ProgramData\UltraGamingMinimal\Persistent.ps1
  ```

  * Creates a **scheduled task** named `UltraGamingMinimalPersistent` that runs:

    * At **logon**
    * After **Windows updates / startup**

* **No:**

  * The script will only apply tweaks **this session**

---

## **Step 4: Verification**

1. Check that services are stopped / set to manual:

   * Open **Task Manager → Services**
2. Verify background apps are disabled:

   * **Settings → Apps → Apps & Features → Background apps**
3. Ensure scheduled tasks for telemetry, indexing, and maintenance are disabled:

   * **Task Scheduler → Microsoft → Windows →** relevant folders

---

## **Step 5: Reverting Changes (Optional)**

* Restore a **system restore point** created before running the script
* Manually re-enable services via **Task Manager → Services**
* Re-enable optional features using PowerShell:

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName <FeatureName>
```

* Re-enable background apps via **Settings → Apps → Background apps**

---

## **Notes**

* Script is **gaming-focused**, safe for high-end PCs.
* Some apps like Microsoft Store or Xbox Game Pass may recreate background tasks; the **persistent scheduled task** ensures they are automatically re-disabled.
* Always run PowerShell **as Administrator** to allow full effect.
* Restart recommended after running for all changes to take effect.
