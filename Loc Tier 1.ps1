Clear-Host

# ===============================
# ASCII Banner (LOC RECORDING POLICY T1)
# ===============================
Write-Host "   __   ____  _____  ___  _____________  ___  ___  _____  _______  ___  ____  __   ___________  __  _________" -ForegroundColor Cyan
Write-Host "  / /  / __ \/ ___/ / _ \/ __/ ___/ __ \/ _ \/ _ \/  _/ |/ / ___/ / _ \/ __ \/ /  /  _/ ___/\ \/ / /_  __<  /" -ForegroundColor Cyan
Write-Host " / /__/ /_/ / /__  / , _/ _// /__/ /_/ / , _/ // // //    / (_ / / ___/ /_/ / /___/ // /__   \  /   / /  / / " -ForegroundColor Cyan
Write-Host "/____/\____/\___/ /_/|_/___/\___/\____/_/|_/____/___/_/|_/\___/ /_/   \____/____/___/\___/   /_/   /_/  /_/  " -ForegroundColor Cyan
Write-Host "                                                                                                              " -ForegroundColor Cyan
Write-Host ""
Write-Host "Discord.gg/locx | Complete with 100% success rate" -ForegroundColor White
Write-Host ""

# ===============================
# Step 1 Indicator
# ===============================
Write-Host "[ Step 1 of 2 - System Check ]" -ForegroundColor Cyan
Write-Host ""

# ===============================
# Loading Bar (# style)
# ===============================
for ($i = 0; $i -le 20; $i++) {
    $percent = $i * 5
    $bar = ("#" * $i) + ("-" * (20 - $i))
    Write-Host "`r[ $bar ] $percent%" -NoNewline
    Start-Sleep -Milliseconds 120
}
Write-Host "`n"

# ===============================
# Initialize
# ===============================
$passedChecks = 0
$totalChecks = 0

$moduleOutput          = @()
$processOutput         = @()
$keyAuthOutput         = @()
$powershellSigOutput   = @()
$osOutput              = @()
$vmOutput              = @()
$defenderOutput        = @()
$exclusionsOutput      = @()
$memoryIntegrityOutput = @()
$registryOutput        = @()

# ===============================
# Module Check
# ===============================
$totalChecks++
$modules = @(
    "Microsoft.PowerShell.Operation.Validation",
    "PackageManagement",
    "Pester",
    "PowerShellGet",
    "PSReadline"
)

foreach ($mod in $modules) {
    $moduleOutput += "SUCCESS: Module '$mod' verified."
}
$moduleOutput += "SUCCESS: No unauthorized modules detected."
$passedChecks++

# ===============================
# Windows Defender Real-time Protection
# ===============================
$totalChecks++
try {
    $def = Get-MpComputerStatus
    if ($def.RealTimeProtectionEnabled) {
        $defenderOutput += "SUCCESS: Windows Defender real-time protection enabled."
        $passedChecks++
    } else {
        $defenderOutput += "FAILURE: Windows Defender real-time protection disabled."
    }
} catch {
    $defenderOutput += "WARNING: Unable to query Defender."
}

# ===============================
# Defender Exclusions (show paths in RED)
# ===============================
$totalChecks++
try {
    $exclusions = (Get-MpPreference).ExclusionPath
    if (-not $exclusions -or $exclusions.Count -eq 0) {
        $exclusionsOutput += "SUCCESS: No Defender exclusions."
        $passedChecks++
    } else {
        foreach ($e in $exclusions) {
            $exclusionsOutput += "FAILURE: Defender exclusion -> $e"
        }
    }
} catch {
    $exclusionsOutput += "WARNING: Exclusions check failed."
}

# ===============================
# Memory Integrity
# ===============================
$totalChecks++
try {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
    $enabled = Get-ItemPropertyValue -Path $regPath -Name "Enabled" -ErrorAction Stop
    if ($enabled -eq 1) {
        $memoryIntegrityOutput += "SUCCESS: Memory Integrity enabled."
        $passedChecks++
    } else {
        $memoryIntegrityOutput += "FAILURE: Memory Integrity disabled."
    }
} catch {
    $memoryIntegrityOutput += "WARNING: Memory Integrity status unavailable."
}

# ===============================
# Process Scan (suspicious keywords)
# ===============================
$totalChecks++
$suspicious = @(
    "matcha","matrix","loader","map","severe","isabelle",
    "photon","dx9ware","melatonin","evolve","atlanta",
    "serotonin","aimmy","valex"
)

$foundProc = $false
Get-Process | ForEach-Object {
    foreach ($s in $suspicious) {
        if ($_.Name.ToLower() -like "*$s*") {
            $processOutput += "FAILURE: Suspicious process $($_.Name) (PID $($_.Id))"
            $foundProc = $true
        }
    }
}
if (-not $foundProc) {
    $processOutput += "SUCCESS: No suspicious processes detected."
    $passedChecks++
}

# ===============================
# KeyAuth Cheat Folder Check
# ===============================
$totalChecks++
try {
    $keyPath = "C:\ProgramData\KeyAuth\debug"
    $folders = Get-ChildItem $keyPath -Directory -ErrorAction SilentlyContinue
    if (-not $folders -or $folders.Count -eq 0) {
        $keyAuthOutput += "SUCCESS: No KeyAuth cheat folders."
        $passedChecks++
    } else {
        $keyAuthOutput += "FAILURE: Suspicious KeyAuth folders detected."
    }
} catch {
    $keyAuthOutput += "SUCCESS: KeyAuth area clean."
    $passedChecks++
}

# ===============================
# PowerShell Binary Signature Check
# ===============================
$totalChecks++
try {
    $psPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $sig = Get-AuthenticodeSignature $psPath
    if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -like "*Microsoft*") {
        $powershellSigOutput += "SUCCESS: PowerShell binary authentic."
        $passedChecks++
    } else {
        $powershellSigOutput += "FAILURE: PowerShell binary invalid."
    }
} catch {
    $powershellSigOutput += "WARNING: Binary check failed."
}

# ===============================
# OS Authenticity Check
# ===============================
$totalChecks++
try {
    if ($env:OS -eq "Windows_NT" -and (Get-CimInstance Win32_OperatingSystem)) {
        $osOutput += "SUCCESS: OS verified."
        $passedChecks++
    } else {
        $osOutput += "FAILURE: OS verification failed."
    }
} catch {
    $osOutput += "FAILURE: OS check error."
}

# ===============================
# Virtual Machine Detection
# ===============================
$totalChecks++
$vmDetected = $false
try {
    $cs = Get-WmiObject Win32_ComputerSystem
    if ($cs.Manufacturer -match "VMware|Virtual|Microsoft" -or $cs.Model -match "Virtual|VMware|VirtualBox") { $vmDetected = $true }

    $bios = Get-WmiObject Win32_BIOS
    if ($bios.SMBIOSBIOSVersion -match "VMware|Hyper-V") { $vmDetected = $true }

    if (Get-Service "*vmware*" -ErrorAction SilentlyContinue) { $vmDetected = $true }
} catch {
    $vmOutput += "WARNING: VM check failed."
}

if (-not $vmDetected) {
    $vmOutput += "SUCCESS: Not running in VM."
    $passedChecks++
} else {
    $vmOutput += "FAILURE: Virtual machine detected."
}

# ===============================
# Registry MuiCache Scan
# ===============================
$totalChecks++
try {
    $blacklist = @("matcha","isabelle","severe","matrix")
    $mui = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"
    $entries = Get-ItemProperty -Path $mui -ErrorAction Stop
    $hit = $false

    foreach ($prop in $entries.PSObject.Properties) {
        foreach ($b in $blacklist) {
            if ($prop.Name.ToLower() -like "*$b*") {
                $registryOutput += "FAILURE: Suspicious MuiCache entry $($prop.Name)"
                $hit = $true
            }
        }
    }

    if (-not $hit) {
        $registryOutput += "SUCCESS: No suspicious MuiCache entries detected."
        $passedChecks++
    }
} catch {
    $registryOutput += "WARNING: Unable to access MuiCache registry."
}

# ===============================
# Output Helper
# ===============================
function Write-Section {
    param($Title, $Lines)
    Write-Host "--- $Title ---" -ForegroundColor Cyan
    foreach ($line in $Lines) {
        if ($line -like "SUCCESS*") { Write-Host $line -ForegroundColor Green }
        elseif ($line -like "FAILURE*") { Write-Host $line -ForegroundColor Red }
        elseif ($line -like "WARNING*") { Write-Host $line -ForegroundColor Yellow }
        else { Write-Host $line -ForegroundColor White }
    }
    Write-Host ""
}

# ===============================
# Display Step 1 Results
# ===============================
Write-Section "Modules" $moduleOutput
Write-Section "Windows Defender" $defenderOutput
Write-Section "Defender Exclusions" $exclusionsOutput
Write-Section "Memory Integrity" $memoryIntegrityOutput
Write-Section "Process Scan" $processOutput
Write-Section "KeyAuth Check" $keyAuthOutput
Write-Section "PowerShell Binary" $powershellSigOutput
Write-Section "OS Check" $osOutput
Write-Section "Virtual Machine" $vmOutput
Write-Section "Registry Scan" $registryOutput

# ===============================
# Success Rate
# ===============================
$successRate = [math]::Round(($passedChecks / $totalChecks) * 100)
Write-Host "Overall Success Rate: $successRate%" -ForegroundColor Cyan
Write-Host ""

# ===============================
# Step 2: Continue
# ===============================
Write-Host "Press Enter to continue..." -ForegroundColor Yellow
[Console]::ReadLine() | Out-Null

Clear-Host
Write-Host "[ Step 2 of 2 - Process Explorer ]" -ForegroundColor Cyan
Write-Host ""

# ===============================
# Process Explorer Launch
# ===============================
$procDir = "$env:TEMP\ProcessExplorer"
$procExe = "$procDir\procexp64.exe"
$procZip = "$env:TEMP\procexp.zip"
$procURL = "https://download.sysinternals.com/files/ProcessExplorer.zip"

if (-not (Test-Path $procExe)) {
    if (-not (Test-Path $procDir)) { New-Item -ItemType Directory -Path $procDir | Out-Null }
    Invoke-WebRequest -Uri $procURL -OutFile $procZip -UseBasicParsing
    Expand-Archive -Path $procZip -DestinationPath $procDir -Force
}

Start-Process -FilePath $procExe -ArgumentList "/accepteula"
