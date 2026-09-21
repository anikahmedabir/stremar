# ============================================================
#       ANIK X CHEATS - HWID GENERATOR TOOL
# ============================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Host.UI.RawUI.WindowTitle = "Anik X Cheats - HWID Generator"

Clear-Host
Write-Host ""
Write-Host "  ╔════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ║          " -NoNewline -ForegroundColor Magenta
Write-Host "★  A N I K  X  H W I D  F I N D E R  ★" -NoNewline -ForegroundColor Cyan
Write-Host "          ║" -ForegroundColor Magenta
Write-Host "  ║                                                        ║" -ForegroundColor Magenta
Write-Host "  ╚════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Start-Sleep -Milliseconds 300

# Get C: Drive Volume Serial
$vol = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").VolumeSerialNumber
if (-not $vol) {
    $vol = (Get-Volume -DriveLetter C -ErrorAction SilentlyContinue).VolumeSerialNumber
}
if (-not $vol) { $vol = "1A2B3C4D" }

# Clean Hex serial to int
$volClean = ($vol -replace '-', '')
try {
    $volInt = [Convert]::ToUInt32($volClean, 16)
} catch {
    $volInt = 12345678
}

$compName = $env:COMPUTERNAME
$rawHwid = "$compName-$volInt"

# Calculate SHA256 Hash
$hasher = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($rawHwid)
$hash = $hasher.ComputeHash($bytes)
$hwid = ($hash | ForEach-Object { "{0:x2}" -f $_ }) -join ""

Set-Clipboard -Value $hwid

Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "YOUR PC HWID IS:" -ForegroundColor White
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "$hwid" -ForegroundColor Yellow
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  │   " -NoNewline -ForegroundColor Green
Write-Host "✔ HWID COPIED TO CLIPBOARD AUTOMATICALLY!" -ForegroundColor Cyan
Write-Host "            │" -ForegroundColor Green
Write-Host "  │                                                        │" -ForegroundColor Green
Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""
Write-Host "  [★] Send this HWID to the Admin to activate your license." -ForegroundColor DarkGray
Write-Host ""
Start-Sleep -Seconds 6
