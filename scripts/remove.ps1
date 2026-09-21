# ============================================================
#       ANIK X CHEATS STREAMER - UNINSTALLER
# ============================================================

$Host.UI.RawUI.WindowTitle = "Anik X Cheats Streamer - Uninstaller"

# --- Admin Privilege Check ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Clear-Host
    Write-Host ""
    Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor Red
    Write-Host "  │   [!] ADMINISTRATOR PRIVILEGES REQUIRED                │" -ForegroundColor Red
    Write-Host "  │   Please right-click PowerShell and 'Run as admin'     │" -ForegroundColor White
    Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor Red
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
Write-Host ""
Write-Host "  ╔════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ║       " -NoNewline -ForegroundColor Magenta
Write-Host "★  A N I K  X  C H E A T S  S T R E A M E R  ★" -NoNewline -ForegroundColor Yellow
Write-Host "   ║" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ║                " -NoNewline -ForegroundColor Magenta
Write-Host "System Uninstallation Utility" -NoNewline -ForegroundColor DarkGray
Write-Host "           ║" -ForegroundColor Magenta
Write-Host "  ╚════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Start-Sleep -Milliseconds 300

function Show-Step {
    param([string]$Step, [string]$Title, [string]$Details)
    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host "$Step" -NoNewline -ForegroundColor Yellow
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host "$Title" -ForegroundColor White
    if ($Details) {
        Write-Host "      └─ $Details" -ForegroundColor DarkGray
    }
}

function Show-Success {
    param([string]$Message)
    Write-Host "      ✔ $Message" -ForegroundColor Green
}

# --- Step 1: Stopping Service ---
Show-Step "01/03" "Terminating Streamer Service..." "Stopping background watcher process"
$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    Show-Success "Service stopped"
} else {
    Show-Success "No active service found"
}
Write-Host ""

# --- Step 2: Unregistering Service ---
Show-Step "02/03" "Unregistering Windows Service..." "Removing service entry from registry"
if (Test-Path $TargetExe) {
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
        Start-Sleep -Milliseconds 800
    }
}
Show-Success "Service unregistered"
Write-Host ""

# --- Step 3: Deleting Files ---
Show-Step "03/03" "Purging System Files & Cache..." "Deleting system binaries and logs"
if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue }
if (Test-Path $LogFile)   { Remove-Item $LogFile   -Force -ErrorAction SilentlyContinue }
Start-Sleep -Milliseconds 500
Show-Success "All components deleted cleanly"
Write-Host ""

# --- Finish Banner ---
Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor Yellow
Write-Host "  │                                                        │" -ForegroundColor Yellow
Write-Host "  │   " -NoNewline -ForegroundColor Yellow
Write-Host "✔  UNINSTALLATION COMPLETED SAFELY" -NoNewline -ForegroundColor White
Write-Host "                   │" -ForegroundColor Yellow
Write-Host "  │                                                        │" -ForegroundColor Yellow
Write-Host "  │   " -NoNewline -ForegroundColor Yellow
Write-Host "▸ Status   : " -NoNewline -ForegroundColor Cyan
Write-Host "All Streamer files completely removed" -NoNewline -ForegroundColor White
Write-Host "        │" -ForegroundColor Yellow
Write-Host "  │   " -NoNewline -ForegroundColor Yellow
Write-Host "▸ Registry : " -NoNewline -ForegroundColor Gray
Write-Host "Cleaned up" -NoNewline -ForegroundColor White
Write-Host "                                   │" -ForegroundColor Yellow
Write-Host "  │                                                        │" -ForegroundColor Yellow
Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [★] Anik X Cheats Streamer has been uninstalled." -ForegroundColor DarkGray
Write-Host ""
Start-Sleep -Seconds 3