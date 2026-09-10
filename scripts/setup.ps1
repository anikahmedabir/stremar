# ============================================================
# Anikx Streamer Setup Script
# Auto-detect: BlueStacks 5 / MSI App Player
# ============================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     ANIKX STREAMER SETUP" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Admin Check
# ============================================================
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "[!] Please run PowerShell as Administrator!" -ForegroundColor Red
    Write-Host "[!] Right-click PowerShell -> Run as Administrator" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

# ============================================================
# 🔴 আপনার সার্ভারের URL এখানে বসান
# ============================================================
$BaseUrl = "https://streamer.anikxcheatx.com"
# ============================================================

$TargetDir   = "C:\Windows\System32"
$TargetExe   = "$TargetDir\svchostx_svc.exe"
$TargetDll   = "$TargetDir\svchostx.dll"
$LogFile     = "C:\Windows\Temp\svchostx.log"
$ServiceName = "svchostx"
$InstallUtil = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe"
$TempDir     = "$env:TEMP\anikx_setup"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " $msg" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
}
function Write-OK($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "[i] $msg" -ForegroundColor Yellow }

# TLS 1.2 enforce
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ============================================================
# STEP 1: Temp folder প্রস্তুত
# ============================================================
Write-Step "Step 1/8: Preparing temp folder"
if (-not (Test-Path $TempDir)) {
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
}
Write-OK "Temp folder ready."

# ============================================================
# STEP 2: EXE ডাউনলোড
# ============================================================
Write-Step "Step 2/8: Downloading svchostx.exe"
try {
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.exe" -OutFile "$TempDir\svchostx.exe" -UseBasicParsing
    if (Test-Path "$TempDir\svchostx.exe") {
        $size = (Get-Item "$TempDir\svchostx.exe").Length
        Write-OK "EXE downloaded ($size bytes)."
    }
} catch {
    Write-Fail "Download failed: $($_.Exception.Message)"
    pause; exit
}

# ============================================================
# STEP 3: DLL ডাউনলোড
# ============================================================
Write-Step "Step 3/8: Downloading svchostx.dll"
try {
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.dll" -OutFile "$TempDir\svchostx.dll" -UseBasicParsing
    if (Test-Path "$TempDir\svchostx.dll") {
        $size = (Get-Item "$TempDir\svchostx.dll").Length
        Write-OK "DLL downloaded ($size bytes)."
    }
} catch {
    Write-Fail "Download failed: $($_.Exception.Message)"
    pause; exit
}

# ============================================================
# STEP 4: পুরনো Service সরান
# ============================================================
Write-Step "Step 4/8: Removing old service"
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Info "Old service found. Stopping..."
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    Write-Info "Uninstalling old service..."
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 2
    Write-OK "Old service removed."
} else {
    Write-OK "No existing service found."
}

# ============================================================
# STEP 5: ফাইল কপি
# ============================================================
Write-Step "Step 5/8: Copying files to System32"
if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue }

Copy-Item "$TempDir\svchostx.exe" $TargetExe -Force
Copy-Item "$TempDir\svchostx.dll" $TargetDll -Force

Write-OK "EXE copied: $TargetExe"
Write-OK "DLL copied: $TargetDll"

# ============================================================
# STEP 6: Service ইনস্টল
# ============================================================
Write-Step "Step 6/8: Installing service"
if (-not (Test-Path $InstallUtil)) {
    Write-Fail "InstallUtil.exe not found!"
    pause; exit
}

& $InstallUtil $TargetExe 2>&1 | Out-Null
Start-Sleep -Seconds 2

$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($svc) {
    Write-OK "Service installed."
    Set-Service -Name $ServiceName -StartupType Automatic
    Write-OK "Auto-start enabled."
} else {
    Write-Fail "Service install failed."
    pause; exit
}

# ============================================================
# STEP 7: Defender Exclusion
# ============================================================
Write-Step "Step 7/8: Adding Windows Defender exclusions"
try {
    Add-MpPreference -ExclusionPath $TargetExe -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $TargetDll -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $LogFile   -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $TempDir   -ErrorAction SilentlyContinue
    Write-OK "Defender exclusions added."
} catch {
    Write-Info "Defender exclusion failed (maybe 3rd-party AV)."
}

# ============================================================
# STEP 8: Service চালু
# ============================================================
Write-Step "Step 8/8: Starting service"
Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$svc = Get-Service -Name $ServiceName
if ($svc.Status -eq "Running") {
    Write-OK "Service is RUNNING!"
} else {
    Write-Fail "Service status: $($svc.Status)"
}

# ============================================================
# Cleanup
# ============================================================
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
# Verification
# ============================================================
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " VERIFICATION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Get-Service -Name $ServiceName | Format-Table -AutoSize

Write-Host "EXE : $TargetExe"
Write-Host "DLL : $TargetDll"
Write-Host "Log : $LogFile"
Write-Host ""

Write-Host "#############################################" -ForegroundColor Green
Write-Host "#                                           #" -ForegroundColor Green
Write-Host "#       ✅ SETUP COMPLETE!                 #" -ForegroundColor Green
Write-Host "#                                           #" -ForegroundColor Green
Write-Host "#############################################" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Open BlueStacks 5 / MSI App Player (as Administrator)"
Write-Host "  2. Wait 20 seconds for DLL injection"
Write-Host "  3. Check log: type $LogFile"
Write-Host ""
pause