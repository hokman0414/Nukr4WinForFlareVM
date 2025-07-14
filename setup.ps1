# Run as Administrator

# Disable Proxy Auto-Detect
try {
    Write-Host "Disabling Proxy Auto-Detect..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name AutoDetect -Value 0
} catch { Write-Warning "Failed to modify proxy settings: $_" }

# Disable Microsoft Defender real-time protection (if module exists)
try {
    Write-Host "Disabling Defender real-time protection..."
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
    Set-MpPreference -DisableBehaviorMonitoring $true
    Set-MpPreference -DisableIOAVProtection $true
    Set-MpPreference -DisableScriptScanning $true
} catch { Write-Warning "Defender settings failed (possibly already disabled or module not available): $_" }

# Disable Defender via registry (GPO equivalent)
try {
    Write-Host "Disabling Defender via registry..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1
} catch { Write-Warning "Failed to set Defender registry: $_" }

# Disable Windows Firewall (Domain profile only)
try {
    Write-Host "Disabling Windows Firewall (Domain profile)..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "EnableFirewall" -Value 0
} catch { Write-Warning "Failed to disable firewall via registry: $_" }

# Disable Windows Automatic Updates via registry
try {
    Write-Host "Disabling Windows Automatic Updates..."
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1
} catch { Write-Warning "Failed to disable updates: $_" }

# Set Execution Policy for Current User
try {
    Write-Host "Setting execution policy to Unrestricted for CurrentUser..."
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
} catch { Write-Warning "Execution policy may be restricted by higher-scope policy: $_" }

# Download Flare-VM install.ps1 to Desktop
try {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $flarePath = "$desktop\install.ps1"
    Write-Host "Downloading Flare-VM installer script to $flarePath"
    (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1', $flarePath)
    Unblock-File $flarePath
    Write-Host "Flare-VM script downloaded and unblocked."
} catch { Write-Warning "Failed to download or unblock Flare-VM script: $_" }

Write-Host " Reboot your system to apply all registry-based policy changes."
