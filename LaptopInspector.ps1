[CmdletBinding()]
param(
    [ValidateSet('Interactive','Quick','Full','Report')]
    [string]$Mode = 'Interactive',
    [string]$ReportPath = ''
)

$ErrorActionPreference = 'SilentlyContinue'
$script:AppRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:ConfigPath = Join-Path $script:AppRoot 'config.json'

function Write-LIPHeader {
    Clear-Host
    Write-Host '=============================================' -ForegroundColor Cyan
    Write-Host '          LaptopInspectorPro v0.1' -ForegroundColor Cyan
    Write-Host '      Windows Laptop Diagnostic Toolkit' -ForegroundColor DarkCyan
    Write-Host '=============================================' -ForegroundColor Cyan
}

function Get-LIPConfig {
    if (Test-Path $script:ConfigPath) {
        try { return Get-Content $script:ConfigPath -Raw | ConvertFrom-Json } catch { }
    }
    return [pscustomobject]@{ Application = [pscustomobject]@{ Name='LaptopInspectorPro'; Version='0.1.0' } }
}

$script:Config = Get-LIPConfig
$modulePath = Join-Path $script:AppRoot 'modules'
Get-ChildItem $modulePath -Filter '*.ps1' -File | Sort-Object Name | ForEach-Object { . $_.FullName }

function Invoke-LIPDiagnostics {
    $results = [ordered]@{}
    $collectors = @(
        'Get-LIPSystemInfo','Get-LIPWindowsInfo','Get-LIPCPUInfo','Get-LIPGPUInfo',
        'Get-LIPRAMInfo','Get-LIPDiskInfo','Get-LIPStorageInfo','Get-LIPBatteryInfo',
        'Get-LIPDisplayInfo','Get-LIPAudioInfo','Get-LIPCameraInfo','Get-LIPNetworkInfo',
        'Get-LIPPortsInfo','Get-LIPTouchInfo','Get-LIPSecurityInfo'
    )
    foreach ($collector in $collectors) {
        if (Get-Command $collector -ErrorAction SilentlyContinue) {
            try { $results[$collector] = & $collector } catch { $results[$collector] = [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
        }
    }
    return [pscustomobject]$results
}

function Show-LIPSummary($data) {
    Write-Host "`nSystem" -ForegroundColor Yellow
    $data.Get-LIPSystemInfo | Format-List
    Write-Host 'CPU' -ForegroundColor Yellow
    $data.Get-LIPCPUInfo | Format-List
    Write-Host 'Memory' -ForegroundColor Yellow
    $data.Get-LIPRAMInfo | Format-List
    Write-Host 'Storage' -ForegroundColor Yellow
    $data.Get-LIPStorageInfo | Format-Table -AutoSize
    Write-Host 'Battery' -ForegroundColor Yellow
    $data.Get-LIPBatteryInfo | Format-List
    Write-Host 'Health Score' -ForegroundColor Yellow
    if (Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue) { Get-LIPHealthScore -Results $data | Format-List }
}

if ($Mode -eq 'Interactive') {
    do {
        Write-LIPHeader
        Write-Host '1. Quick inspection'
        Write-Host '2. Full inspection'
        Write-Host '3. Generate report'
        Write-Host '4. Exit'
        $choice = Read-Host 'Select an option'
        switch ($choice) {
            '1' { $data = Invoke-LIPDiagnostics; Show-LIPSummary $data; Read-Host 'Press Enter to continue' }
            '2' { $data = Invoke-LIPDiagnostics; Show-LIPSummary $data; Read-Host 'Press Enter to continue' }
            '3' { $data = Invoke-LIPDiagnostics; if (Get-Command Export-LIPReport -ErrorAction SilentlyContinue) { Export-LIPReport -Results $data -OutputPath $ReportPath }; Read-Host 'Press Enter to continue' }
            '4' { break }
        }
    } while ($true)
} else {
    $data = Invoke-LIPDiagnostics
    if ($Mode -eq 'Report' -and (Get-Command Export-LIPReport -ErrorAction SilentlyContinue)) { Export-LIPReport -Results $data -OutputPath $ReportPath }
    else { Show-LIPSummary $data }
}
