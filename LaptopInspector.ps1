[CmdletBinding()]
param(
    [ValidateSet('Interactive','Inspection','Report','Purchase')]
    [string]$Mode = 'Interactive',
    [string]$ReportPath = '',
    [Nullable[double]]$AskingPriceINR
)

$ErrorActionPreference = 'SilentlyContinue'
$script:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ConfigPath = Join-Path $script:AppRoot 'config.json'

function Write-LIPHeader {
    Clear-Host
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host '              LaptopInspectorPro v0.3' -ForegroundColor Cyan
    Write-Host '       Windows Laptop Diagnostic Toolkit' -ForegroundColor DarkCyan
    Write-Host '==================================================' -ForegroundColor Cyan
}

function Get-LIPConfig {
    if (Test-Path $script:ConfigPath) {
        try { return Get-Content $script:ConfigPath -Raw | ConvertFrom-Json } catch { }
    }
    return [pscustomobject]@{ Application = [pscustomobject]@{ Name='LaptopInspectorPro'; Version='0.3.0' } }
}

$script:Config = Get-LIPConfig
$modulePath = Join-Path $script:AppRoot 'modules'
Get-ChildItem $modulePath -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object { . $_.FullName }

function Invoke-LIPInspection {
    $results = [ordered]@{}
    $collectors = @(
        'Get-LIPSystemInfo','Get-LIPWindowsInfo','Get-LIPCPUInfo','Get-LIPGPUInfo',
        'Get-LIPRAMInfo','Get-LIPDiskInfo','Get-LIPStorageInfo','Get-LIPBatteryInfo',
        'Get-LIPDisplayInfo','Get-LIPAudioInfo','Get-LIPCameraInfo','Get-LIPNetworkInfo',
        'Get-LIPPortsInfo','Get-LIPTouchInfo','Get-LIPSecurityInfo',
        'Get-LIPStorageHealthInfo','Get-LIPDriverSummary','Get-LIPThermalInfo'
    )
    foreach ($collector in $collectors) {
        if (Get-Command $collector -ErrorAction SilentlyContinue) {
            try { $results[$collector] = & $collector } catch { $results[$collector] = [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
        }
    }
    return [pscustomobject]$results
}

function Get-LIPInspectionScore($data) {
    if (Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue) { return Get-LIPHealthScore -Results $data }
    return $null
}

function Show-LIPInspection($data) {
    Write-Host "`n================ INSPECTION RESULTS ================" -ForegroundColor Cyan
    Write-Host "`nSYSTEM" -ForegroundColor Yellow
    $data.'Get-LIPSystemInfo' | Format-List
    Write-Host 'WINDOWS' -ForegroundColor Yellow
    $data.'Get-LIPWindowsInfo' | Format-List
    Write-Host 'CPU' -ForegroundColor Yellow
    $data.'Get-LIPCPUInfo' | Format-List
    Write-Host 'GPU' -ForegroundColor Yellow
    $data.'Get-LIPGPUInfo' | Format-Table -AutoSize
    Write-Host 'RAM' -ForegroundColor Yellow
    $data.'Get-LIPRAMInfo' | Format-List
    Write-Host 'DISKS' -ForegroundColor Yellow
    $data.'Get-LIPDiskInfo' | Format-Table -AutoSize
    Write-Host 'STORAGE' -ForegroundColor Yellow
    $data.'Get-LIPStorageInfo' | Format-Table -AutoSize
    Write-Host 'STORAGE HEALTH' -ForegroundColor Yellow
    if($data.'Get-LIPStorageHealthInfo'.Disks){ $data.'Get-LIPStorageHealthInfo'.Disks | Format-Table FriendlyName,MediaType,BusType,HealthStatus,TemperatureC,WearPercent,PowerOnHours -AutoSize } else { $data.'Get-LIPStorageHealthInfo' | Format-List }
    Write-Host 'BATTERY' -ForegroundColor Yellow
    $data.'Get-LIPBatteryInfo' | Format-List
    Write-Host 'DISPLAY' -ForegroundColor Yellow
    $data.'Get-LIPDisplayInfo' | Format-Table -AutoSize
    Write-Host 'AUDIO' -ForegroundColor Yellow
    $data.'Get-LIPAudioInfo' | Format-Table -AutoSize
    Write-Host 'CAMERA' -ForegroundColor Yellow
    $data.'Get-LIPCameraInfo' | Format-Table -AutoSize
    Write-Host 'NETWORK' -ForegroundColor Yellow
    $data.'Get-LIPNetworkInfo' | Format-Table -AutoSize
    Write-Host 'PORTS / DEVICES' -ForegroundColor Yellow
    $data.'Get-LIPPortsInfo' | Format-Table -AutoSize
    Write-Host 'TOUCH / DIGITIZER' -ForegroundColor Yellow
    $data.'Get-LIPTouchInfo' | Format-List
    Write-Host 'SECURITY' -ForegroundColor Yellow
    $data.'Get-LIPSecurityInfo' | Format-List
    Write-Host 'DRIVER HEALTH' -ForegroundColor Yellow
    $data.'Get-LIPDriverSummary' | Format-List
    Write-Host 'THERMALS' -ForegroundColor Yellow
    $data.'Get-LIPThermalInfo'.Zones | Format-Table -AutoSize

    $score = Get-LIPInspectionScore $data
    Write-Host "`n================ HEALTH SCORE ================" -ForegroundColor Cyan
    if($score){
        Write-Host ("Overall Health: {0}/100 - {1}" -f $score.Overall,$score.Grade) -ForegroundColor Green
        $score.Components.PSObject.Properties | ForEach-Object { Write-Host ("{0,-14} {1,6}/100" -f $_.Name,$_.Value) }
    } else { Write-Host 'Health scoring unavailable.' -ForegroundColor Yellow }
    Write-Host "`nInspection mode intentionally does NOT show BUY / NEGOTIATE / SKIP or pricing."
}

function Show-LIPPurchaseResult($assessment) {
    Write-Host "`n================ PURCHASING ASSESSMENT ================" -ForegroundColor Cyan
    Write-Host ("Overall health : {0}/100" -f $assessment.OverallScore)
    Write-Host "Verdict        : $($assessment.Verdict)" -ForegroundColor $(if($assessment.Verdict -eq 'BUY'){'Green'}elseif($assessment.Verdict -eq 'NEGOTIATE'){'Yellow'}else{'Red'})
    Write-Host "Confidence     : $($assessment.Confidence)"
    if($null -ne $assessment.AskingPriceINR){
        Write-Host ("Asking price   : ₹{0:N0}" -f $assessment.AskingPriceINR)
        if($assessment.EstimatedFairValueINR){ Write-Host ("Fair-value heuristic: ₹{0:N0}" -f $assessment.EstimatedFairValueINR); Write-Host "Price verdict  : $($assessment.PriceVerdict)" }
    }
    if($assessment.RiskFlags.Count){ Write-Host "`nRisk flags:" -ForegroundColor Yellow; $assessment.RiskFlags | ForEach-Object { Write-Host " - $_" } } else { Write-Host "`nNo major inspection risk flags detected." -ForegroundColor Green }
}

function Invoke-LIPPurchase {
    $data = Invoke-LIPInspection
    $price = Read-Host 'Enter asking price in INR'
    $parsed = $null
    if([double]::TryParse($price,[ref]$parsed) -and $parsed -gt 0){
        $assessment = Get-LIPPurchaseAssessment -Results $data -AskingPriceINR $parsed
    } else {
        Write-Host 'Invalid price. Purchasing assessment requires a valid asking price.' -ForegroundColor Red
        return
    }
    Show-LIPPurchaseResult $assessment
}

if ($Mode -eq 'Interactive') {
    do {
        Write-LIPHeader
        Write-Host '1. Inspection'
        Write-Host '2. Purchasing'
        Write-Host '3. Exit'
        $choice = Read-Host 'Select an option'
        switch ($choice) {
            '1' { $data = Invoke-LIPInspection; Show-LIPInspection $data; Read-Host 'Press Enter to continue' }
            '2' { Invoke-LIPPurchase; Read-Host 'Press Enter to continue' }
            '3' { break }
        }
    } while ($true)
} elseif ($Mode -eq 'Inspection') {
    Show-LIPInspection (Invoke-LIPInspection)
} elseif ($Mode -eq 'Purchase') {
    $data = Invoke-LIPInspection
    if($null -eq $AskingPriceINR -or $AskingPriceINR -le 0){ throw 'Purchase mode requires -AskingPriceINR with a value greater than zero.' }
    Show-LIPPurchaseResult (Get-LIPPurchaseAssessment -Results $data -AskingPriceINR $AskingPriceINR)
} elseif ($Mode -eq 'Report') {
    $data = Invoke-LIPInspection
    if (Get-Command Export-LIPReport -ErrorAction SilentlyContinue) { Export-LIPReport -Results $data -OutputPath $ReportPath }
}
