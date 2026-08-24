[CmdletBinding()]
param(
    [ValidateSet('Interactive','Inspection','Report','Purchase')]
    [string]$Mode = 'Interactive',
    [string]$ReportPath = ''
)

$ErrorActionPreference = 'SilentlyContinue'
$script:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ConfigPath = Join-Path $script:AppRoot 'config.json'

function Write-LIPHeader {
    Clear-Host
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host '              LaptopInspectorPro v0.4' -ForegroundColor Cyan
    Write-Host '       Windows Laptop Diagnostic Toolkit' -ForegroundColor DarkCyan
    Write-Host '==================================================' -ForegroundColor Cyan
}

function Show-LIPPleaseWait {
    Clear-Host
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host '              LaptopInspectorPro v0.4' -ForegroundColor Cyan
    Write-Host '==================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '          Please wait...' -ForegroundColor Yellow
    Write-Host '       Inspecting your device' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'Collecting hardware and system information.' -ForegroundColor DarkGray
    Write-Host 'Please do not close this window.' -ForegroundColor DarkGray
}

function Get-LIPConfig {
    if (Test-Path $script:ConfigPath) {
        try { return Get-Content $script:ConfigPath -Raw | ConvertFrom-Json } catch { }
    }
    return [pscustomobject]@{ Application = [pscustomobject]@{ Name='LaptopInspectorPro'; Version='0.4.0' } }
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

function Write-LIPObjectDetails {
    param([string]$Title, $Object)
    Write-Host "`n================ $Title ================" -ForegroundColor Cyan
    if($null -eq $Object){ Write-Host 'No data was returned.' -ForegroundColor Yellow; return }
    @($Object) | ForEach-Object {
        $_.PSObject.Properties | ForEach-Object {
            $value = $_.Value
            if($null -eq $value){ $value = 'Not available' }
            elseif($value -is [array]){ $value = ($value | Out-String).Trim() }
            Write-Host ("{0,-28}: {1}" -f $_.Name,$value)
        }
    }
}

function Show-LIPInspectionSummary($data) {
    Clear-Host
    Write-Host '================ INSPECTION SUMMARY ================' -ForegroundColor Cyan
    Write-Host "`nSYSTEM" -ForegroundColor Yellow
    $data.'Get-LIPSystemInfo' | Format-List
    Write-Host 'CPU' -ForegroundColor Yellow
    $data.'Get-LIPCPUInfo' | Format-List
    Write-Host 'GPU' -ForegroundColor Yellow
    $data.'Get-LIPGPUInfo' | Format-Table -AutoSize
    Write-Host 'RAM' -ForegroundColor Yellow
    $data.'Get-LIPRAMInfo' | Format-List
    Write-Host 'STORAGE' -ForegroundColor Yellow
    $data.'Get-LIPStorageInfo' | Format-Table -AutoSize
    Write-Host 'BATTERY' -ForegroundColor Yellow
    $data.'Get-LIPBatteryInfo' | Format-List
    Write-Host 'DISPLAY' -ForegroundColor Yellow
    $data.'Get-LIPDisplayInfo' | Format-Table -AutoSize
    Write-Host 'NETWORK' -ForegroundColor Yellow
    $data.'Get-LIPNetworkInfo' | Format-Table -AutoSize
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
        $score.Components.PSObject.Properties | ForEach-Object { Write-Host ("{0,-18} {1,6}/100" -f $_.Name,$_.Value) }
    } else { Write-Host 'Health scoring unavailable.' -ForegroundColor Yellow }
}

function Show-LIPInspectionDetails($data) {
    do {
        Clear-Host
        Write-Host '================ VIEW EACH RESULT ================' -ForegroundColor Cyan
        Write-Host '1. System information'
        Write-Host '2. Windows information'
        Write-Host '3. CPU details'
        Write-Host '4. GPU details'
        Write-Host '5. RAM / Memory details'
        Write-Host '6. Disk details'
        Write-Host '7. Storage details'
        Write-Host '8. Storage health / SMART details'
        Write-Host '9. Battery details'
        Write-Host '10. Display details'
        Write-Host '11. Audio details'
        Write-Host '12. Camera details'
        Write-Host '13. Network details'
        Write-Host '14. Ports / devices details'
        Write-Host '15. Touch / digitizer details'
        Write-Host '16. Security details'
        Write-Host '17. Driver health details'
        Write-Host '18. Thermal details'
        Write-Host '19. Health score details'
        Write-Host '20. Exit'
        $choice = Read-Host "`nSelect a result to view"
        $obj = $null; $title = ''
        switch($choice){
            '1' {$obj=$data.'Get-LIPSystemInfo';$title='SYSTEM INFORMATION'}
            '2' {$obj=$data.'Get-LIPWindowsInfo';$title='WINDOWS INFORMATION'}
            '3' {$obj=$data.'Get-LIPCPUInfo';$title='CPU DETAILS'}
            '4' {$obj=$data.'Get-LIPGPUInfo';$title='GPU DETAILS'}
            '5' {$obj=$data.'Get-LIPRAMInfo';$title='RAM / MEMORY DETAILS'}
            '6' {$obj=$data.'Get-LIPDiskInfo';$title='DISK DETAILS'}
            '7' {$obj=$data.'Get-LIPStorageInfo';$title='STORAGE DETAILS'}
            '8' {$obj=$data.'Get-LIPStorageHealthInfo';$title='STORAGE HEALTH / SMART DETAILS'}
            '9' {$obj=$data.'Get-LIPBatteryInfo';$title='BATTERY DETAILS'}
            '10' {$obj=$data.'Get-LIPDisplayInfo';$title='DISPLAY DETAILS'}
            '11' {$obj=$data.'Get-LIPAudioInfo';$title='AUDIO DETAILS'}
            '12' {$obj=$data.'Get-LIPCameraInfo';$title='CAMERA DETAILS'}
            '13' {$obj=$data.'Get-LIPNetworkInfo';$title='NETWORK DETAILS'}
            '14' {$obj=$data.'Get-LIPPortsInfo';$title='PORTS / DEVICES DETAILS'}
            '15' {$obj=$data.'Get-LIPTouchInfo';$title='TOUCH / DIGITIZER DETAILS'}
            '16' {$obj=$data.'Get-LIPSecurityInfo';$title='SECURITY DETAILS'}
            '17' {$obj=$data.'Get-LIPDriverSummary';$title='DRIVER HEALTH DETAILS'}
            '18' {$obj=$data.'Get-LIPThermalInfo';$title='THERMAL DETAILS'}
            '19' {
                Clear-Host
                $score=Get-LIPInspectionScore $data
                Write-Host '================ HEALTH SCORE DETAILS ================' -ForegroundColor Cyan
                if($score){
                    Write-Host ("Overall Health : {0}/100" -f $score.Overall) -ForegroundColor Green
                    Write-Host "Grade          : $($score.Grade)"
                    Write-Host ''
                    $score.Components.PSObject.Properties | ForEach-Object { Write-Host ("{0,-20}: {1}/100" -f $_.Name,$_.Value) }
                } else { Write-Host 'Health scoring unavailable.' }
                Read-Host "`nPress Enter to return"
                continue
            }
            '20' { return }
            default { continue }
        }
        Clear-Host
        Write-LIPObjectDetails -Title $title -Object $obj
        Write-Host "`nPress Enter to return to the result list..." -ForegroundColor DarkCyan
        Read-Host
    } while($true)
}

function Show-LIPInspection($data) {
    Show-LIPInspectionSummary $data
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host '1. View each result'
    Write-Host '2. Exit inspection'
    $choice = Read-Host 'Select an option'
    if($choice -eq '1'){ Show-LIPInspectionDetails $data }
}

function Show-LIPPurchaseResult($assessment) {
    Write-Host "`n================ PURCHASING ASSESSMENT ================" -ForegroundColor Cyan
    Write-Host ("Overall health : {0}/100" -f $assessment.OverallScore)
    Write-Host "Decision       : $($assessment.Verdict)" -ForegroundColor $(if($assessment.ShouldBuy){'Green'}else{'Red'})
    Write-Host "Confidence     : $($assessment.Confidence)"
    Write-Host "`n$($assessment.RecommendationMessage)" -ForegroundColor $(if($assessment.ShouldBuy){'Green'}else{'Red'})
    if($assessment.RiskFlags.Count){ Write-Host "`nRisk flags:" -ForegroundColor Yellow; $assessment.RiskFlags | ForEach-Object { Write-Host " - $_" } } else { Write-Host "`nNo major inspection risk flags detected." -ForegroundColor Green }
}

function Invoke-LIPPurchase {
    Show-LIPPleaseWait
    $data = Invoke-LIPInspection
    Clear-Host
    Show-LIPPurchaseResult (Get-LIPPurchaseAssessment -Results $data)
}

if ($Mode -eq 'Interactive') {
    do {
        Write-LIPHeader
        Write-Host '1. Inspection'
        Write-Host '2. Purchasing'
        Write-Host '3. Exit'
        $choice = Read-Host 'Select an option'
        switch ($choice) {
            '1' { Show-LIPPleaseWait; $data = Invoke-LIPInspection; Show-LIPInspection $data }
            '2' { Invoke-LIPPurchase; Read-Host 'Press Enter to continue' }
            '3' { break }
        }
    } while ($true)
} elseif ($Mode -eq 'Inspection') {
    Show-LIPPleaseWait
    Show-LIPInspection (Invoke-LIPInspection)
} elseif ($Mode -eq 'Purchase') {
    Show-LIPPleaseWait
    $data = Invoke-LIPInspection
    Clear-Host
    Show-LIPPurchaseResult (Get-LIPPurchaseAssessment -Results $data)
} elseif ($Mode -eq 'Report') {
    Show-LIPPleaseWait
    $data = Invoke-LIPInspection
    if (Get-Command Export-LIPReport -ErrorAction SilentlyContinue) { Export-LIPReport -Results $data -OutputPath $ReportPath }
}
