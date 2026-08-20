[CmdletBinding()]
param(
    [ValidateSet('Interactive','Quick','Full','Report','Purchase')]
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

function Invoke-LIPDiagnostics {
    param([switch]$Deep)
    $results = [ordered]@{}
    $collectors = @(
        'Get-LIPSystemInfo','Get-LIPWindowsInfo','Get-LIPCPUInfo','Get-LIPGPUInfo',
        'Get-LIPRAMInfo','Get-LIPDiskInfo','Get-LIPStorageInfo','Get-LIPBatteryInfo',
        'Get-LIPDisplayInfo','Get-LIPAudioInfo','Get-LIPCameraInfo','Get-LIPNetworkInfo',
        'Get-LIPPortsInfo','Get-LIPTouchInfo','Get-LIPSecurityInfo'
    )
    if($Deep){ $collectors += @('Get-LIPStorageHealthInfo','Get-LIPDriverSummary','Get-LIPThermalInfo') }
    foreach ($collector in $collectors) {
        if (Get-Command $collector -ErrorAction SilentlyContinue) {
            try { $results[$collector] = & $collector } catch { $results[$collector] = [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
        }
    }
    return [pscustomobject]$results
}

function Show-LIPSummary($data) {
    Write-Host "`nSYSTEM" -ForegroundColor Yellow
    $data.'Get-LIPSystemInfo' | Format-List
    Write-Host 'CPU' -ForegroundColor Yellow
    $data.'Get-LIPCPUInfo' | Format-List
    Write-Host 'MEMORY' -ForegroundColor Yellow
    $data.'Get-LIPRAMInfo' | Format-List
    Write-Host 'STORAGE' -ForegroundColor Yellow
    $data.'Get-LIPStorageInfo' | Format-Table -AutoSize
    if($data.'Get-LIPStorageHealthInfo'){
        Write-Host 'STORAGE HEALTH' -ForegroundColor Yellow
        $data.'Get-LIPStorageHealthInfo'.Disks | Format-Table FriendlyName,MediaType,BusType,HealthStatus,TemperatureC,WearPercent,PowerOnHours -AutoSize
    }
    Write-Host 'BATTERY' -ForegroundColor Yellow
    $data.'Get-LIPBatteryInfo' | Format-List
    if($data.'Get-LIPDriverSummary'){
        Write-Host 'DRIVER HEALTH' -ForegroundColor Yellow
        $data.'Get-LIPDriverSummary' | Select-Object Status,DeviceCount,ProblemCount,Health | Format-List
    }
    if($data.'Get-LIPThermalInfo'){
        Write-Host 'THERMALS' -ForegroundColor Yellow
        $data.'Get-LIPThermalInfo'.Zones | Format-Table -AutoSize
    }
    Write-Host 'HEALTH SCORE' -ForegroundColor Yellow
    if (Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue) { Get-LIPHealthScore -Results $data | Format-List }
}

function Show-LIPPurchaseResult($assessment) {
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host '             USED-LAPTOP ASSESSMENT' -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Overall score : $($assessment.OverallScore)/100"
    Write-Host "Verdict       : $($assessment.Verdict)" -ForegroundColor $(if($assessment.Verdict -eq 'BUY'){'Green'}elseif($assessment.Verdict -eq 'NEGOTIATE'){'Yellow'}else{'Red'})
    Write-Host "Confidence    : $($assessment.Confidence)"
    if($null -ne $assessment.AskingPriceINR){ Write-Host ("Asking price  : ₹{0:N0}" -f $assessment.AskingPriceINR); if($assessment.EstimatedFairValueINR){Write-Host ("Fair-value heuristic: ₹{0:N0}" -f $assessment.EstimatedFairValueINR);Write-Host "Price verdict  : $($assessment.PriceVerdict)"} }
    if($assessment.RiskFlags.Count){ Write-Host "`nRisk flags:" -ForegroundColor Yellow; $assessment.RiskFlags | ForEach-Object { Write-Host " - $_" } } else { Write-Host "`nNo major inspection risk flags detected." -ForegroundColor Green }
    Write-Host "`nNote: fair value is an inspection heuristic, not a live market valuation."
}

if ($Mode -eq 'Interactive') {
    do {
        Write-LIPHeader
        Write-Host '1. Quick inspection'
        Write-Host '2. Full inspection'
        Write-Host '3. Generate full report'
        Write-Host '4. Used-laptop assessment'
        Write-Host '5. Exit'
        $choice = Read-Host 'Select an option'
        switch ($choice) {
            '1' { $data = Invoke-LIPDiagnostics; Show-LIPSummary $data; Read-Host 'Press Enter to continue' }
            '2' { $data = Invoke-LIPDiagnostics -Deep; Show-LIPSummary $data; Read-Host 'Press Enter to continue' }
            '3' { $data = Invoke-LIPDiagnostics -Deep; if (Get-Command Export-LIPReport -ErrorAction SilentlyContinue) { Export-LIPReport -Results $data -OutputPath $ReportPath }; Read-Host 'Press Enter to continue' }
            '4' { $data = Invoke-LIPDiagnostics -Deep; $price = Read-Host 'Enter asking price in INR (optional)'; $parsed=$null; if([double]::TryParse($price,[ref]$parsed)){ $assessment=Get-LIPPurchaseAssessment -Results $data -AskingPriceINR $parsed } else { $assessment=Get-LIPPurchaseAssessment -Results $data }; Show-LIPPurchaseResult $assessment; Read-Host 'Press Enter to continue' }
            '5' { break }
        }
    } while ($true)
} else {
    $data = if($Mode -eq 'Quick'){Invoke-LIPDiagnostics}else{Invoke-LIPDiagnostics -Deep}
    if ($Mode -eq 'Report' -and (Get-Command Export-LIPReport -ErrorAction SilentlyContinue)) { Export-LIPReport -Results $data -OutputPath $ReportPath }
    elseif ($Mode -eq 'Purchase') { Show-LIPPurchaseResult (Get-LIPPurchaseAssessment -Results $data -AskingPriceINR $AskingPriceINR) }
    else { Show-LIPSummary $data }
}
