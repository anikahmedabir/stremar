# ============================================================
# Anikx Streamer - Uninstall Script
# ============================================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "     ANIKX STREAMER UNINSTALL" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Admin Check
# ============================================================
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "[!] Please run PowerShell as Administrator!" -ForegroundColor Red
    Write-Host "[!] Right-click PowerShell -> Run as Administrator" -ForegroundColor Yellow
    pause
    exit
}

$TargetExe   = "C:\Windows\System32\svchostx_svc.exe"
$TargetDll   = "C:\Windows\System32\svchostx.dll"
$LogFile     = "C:\Windows\Temp\svchostx.log"
$ServiceName = "svchostx"
$InstallUtil = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe"

function Write-OK($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info($msg) { Write-Host "[i] $msg" -ForegroundColor Yellow }

# ============================================================
# STEP 1: Service Stop
# ============================================================
Write-Host "[1/4] Stopping service..." -ForegroundColor Yellow
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-OK "Service stopped."
} else {
    Write-Info "Service not found."
}

# ============================================================
# STEP 2: Service Uninstall
# ============================================================
Write-Host "[2/4] Uninstalling service..." -ForegroundColor Yellow
if (Test-Path $TargetExe) {
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
        Start-Sleep -Seconds 2
        Write-OK "Service uninstalled."
    }
} else {
    Write-Info "EXE not found."
}

# ============================================================
# STEP 3: Remove Files
# ============================================================
Write-Host "[3/4] Removing files..." -ForegroundColor Yellow
if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue; Write-OK "EXE removed." }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue; Write-OK "DLL removed." }
if (Test-Path $LogFile)   { Remove-Item $LogFile   -Force -ErrorAction SilentlyContinue; Write-OK "Log removed." }

# ============================================================
# STEP 4: Verify
# ============================================================
Write-Host "[4/4] Verifying..." -ForegroundColor Yellow
$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($svc) {
    Write-Host "[!] Service still exists!" -ForegroundColor Red
} else {
    Write-OK "Service fully removed."
}

Write-Host ""
Write-Host "#############################################" -ForegroundColor Green
Write-Host "#       ✅ UNINSTALL COMPLETE!             #" -ForegroundColor Green
Write-Host "#############################################" -ForegroundColor Green
Write-Host ""
pause