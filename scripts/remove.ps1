# ============================================================
# Anikx Streamer Remove - Branded Edition
# ============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host ""
    Write-Host "  Please run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Start-Sleep -Seconds 3
    exit
}

$TargetExe   = "C:\Windows\System32\svchostx_svc.exe"
$TargetDll   = "C:\Windows\System32\svchostx.dll"
$LogFile     = "C:\Windows\Temp\svchostx.log"
$ServiceName = "svchostx"
$InstallUtil = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe"

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
Write-Host "Uninstalling..." -NoNewline -ForegroundColor White
Write-Host "                ║" -ForegroundColor Magenta
Write-Host "  ║                                                  ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Start-Sleep -Milliseconds 400

# ============================================================
# STEP 1: Stopping
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "1/3" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Stopping Anikx Streamer..." -ForegroundColor White

$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# ============================================================
# STEP 2: Removing
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "2/3" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Removing Anikx files..." -ForegroundColor White

if (Test-Path $TargetExe) {
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
        Start-Sleep -Seconds 2
    }
}

if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue }
if (Test-Path $LogFile)   { Remove-Item $LogFile   -Force -ErrorAction SilentlyContinue }

# ============================================================
# STEP 3: Cleanup
# ============================================================
Write-Host "  [ " -NoNewline -ForegroundColor DarkGray
Write-Host "3/3" -NoNewline -ForegroundColor Yellow
Write-Host " ] " -NoNewline -ForegroundColor DarkGray
Write-Host "Cleaning up..." -ForegroundColor White

Start-Sleep -Seconds 1

# ============================================================
# DONE
# ============================================================
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║                                                  ║" -ForegroundColor Yellow
Write-Host "  ║         " -NoNewline -ForegroundColor Yellow
Write-Host "✅ ANIKX STREAMER REMOVED" -NoNewline -ForegroundColor White
Write-Host "          ║" -ForegroundColor Yellow
Write-Host "  ║                                                  ║" -ForegroundColor Yellow
Write-Host "  ║          " -NoNewline -ForegroundColor Yellow
Write-Host "All files deleted safely." -NoNewline -ForegroundColor Cyan
Write-Host "          ║" -ForegroundColor Yellow
Write-Host "  ║                                                  ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 3