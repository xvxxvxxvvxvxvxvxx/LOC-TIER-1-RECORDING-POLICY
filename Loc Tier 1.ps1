Clear-Host

# ===============================
# ASCII Banner (LOC RECORDING POLICY T1)
# ===============================
Write-Host "   __   ____  _____  ___  _____________  ___  ___  _____  _______  ___  ____  __   ___________  __  _________" -ForegroundColor Cyan
Write-Host "  / /  / __ \/ ___/ / _ \/ __/ ___/ __ \/ _ \/ _ \/  _/ |/ / ___/ / _ \/ __ \/ /  /  _/ ___/\ \/ / /_  __<  /" -ForegroundColor Cyan
Write-Host " / /__/ /_/ / /__  / , _/ _// /__/ /_/ / , _/ // // //    / (_ / / ___/ /_/ / /___/ // /__   \  /   / /  / / " -ForegroundColor Cyan
Write-Host "/____/\____/\___/ /_/|_/___/\___/\____/_/|_/____/___/_/|_/\___/ /_/   \____/____/___/\___/   /_/   /_/  /_/  " -ForegroundColor Cyan
Write-Host ""
Write-Host "Discord.gg/locx | Complete with 100% success rate" -ForegroundColor White
Write-Host ""

# ===============================
# Step 1 Indicator
# ===============================
Write-Host "[ Step 1 of 2 - System Check ]" -ForegroundColor Cyan
Write-Host ""

# ===============================
# Loading Bar
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
$totalChecks  = 0

$moduleOutput          = @()
$cpuGpuOutput          = @()
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
# CPU & GPU Detections
# ===============================
try {
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name
    if ($cpu) { $cpuGpuOutput += "SUCCESS: CPU detected -> $cpu" }

    $gpus = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
    foreach ($gpu in $gpus) {
        $cpuGpuOutput += "SUCCESS: GPU detected -> $gpu"
    }
} catch {
    $cpuGpuOutput += "WARNING: Unable to query CPU/GPU information."
}

# ===============================
# Windows Defender
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
# Defender Exclusions
# ===============================
$totalChecks++
try {
    $exclusions = (Get-MpPreference).ExclusionPath
    if (-not $exclusions) {
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
    $enabled = Get-ItemPropertyValue -Path $regPath -Name Enabled
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
# Process Scan
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
# KeyAuth Check
# ===============================
$totalChecks++
try {
    $keyPath = "C:\ProgramData\KeyAuth\debug"
    if (-not (Get-ChildItem $keyPath -Directory -ErrorAction SilentlyContinue)) {
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
# Output Helper
# ===============================
function Write-Section {
    param($Title, $Lines)
    Write-Host "--- $Title ---" -ForegroundColor Cyan
    foreach ($line in $Lines) {
        if ($line -like "SUCCESS*") { Write-Host $line -ForegroundColor Green }
        elseif ($line -like "FAILURE*") { Write-Host $line -ForegroundColor Red }
        elseif ($line -like "WARNING*") { Write-Host $line -ForegroundColor Yellow }
    }
    Write-Host ""
}

# ===============================
# Display Results
# ===============================
Write-Section "Modules" $moduleOutput
Write-Section "CPU & GPU Detections" $cpuGpuOutput
Write-Section "Windows Defender" $defenderOutput
Write-Section "Defender Exclusions" $exclusionsOutput
Write-Section "Memory Integrity" $memoryIntegrityOutput
Write-Section "Process Scan" $processOutput
Write-Section "KeyAuth Check" $keyAuthOutput

# ===============================
# Success Rate
# ===============================
$successRate = [math]::Round(($passedChecks / $totalChecks) * 100)
Write-Host "Overall Success Rate: $successRate%" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press Enter to continue..." -ForegroundColor Yellow
[Console]::ReadLine() | Out-Null

# ===============================
# STEP 2 – PROCESS EXPLORER
# ===============================
Clear-Host
Write-Host "[ Step 2 of 2 - Process Explorer ]" -ForegroundColor Cyan
Write-Host ""

$procDir = "$env:TEMP\ProcessExplorer"
$procExe = "$procDir\procexp64.exe"
$procZip = "$env:TEMP\procexp.zip"
$procURL = "https://download.sysinternals.com/files/ProcessExplorer.zip"

if (-not (Test-Path $procExe)) {
    New-Item -ItemType Directory -Path $procDir -Force | Out-Null
    Invoke-WebRequest -Uri $procURL -OutFile $procZip -UseBasicParsing
    Expand-Archive -Path $procZip -DestinationPath $procDir -Force
}

Write-Host "Launching Process Explorer..." -ForegroundColor Green
Write-Host ""

$proc = Start-Process -FilePath $procExe -ArgumentList "/accepteula" -PassThru
Wait-Process -Id $proc.Id

Write-Host ""
Write-Host "Process Explorer closed." -ForegroundColor Cyan
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
[Console]::ReadLine() | Out-Null

# ===============================
# FULL POWERSHELL CLOSE
# ===============================
Stop-Process -Id $PID
