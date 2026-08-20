function Get-LIPGPUInfo {
    try {
        $gpus = @(Get-CimInstance Win32_VideoController)
        return @($gpus | ForEach-Object {
            [pscustomobject]@{ Status='OK'; Name=$_.Name; AdapterRAMGB=if($_.AdapterRAM){[math]::Round($_.AdapterRAM/1GB,2)}else{$null}; DriverVersion=$_.DriverVersion; DriverDate=$_.DriverDate; Resolution=if($_.CurrentHorizontalResolution){"$($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution)"}else{$null}; RefreshRate=$_.CurrentRefreshRate }
        })
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
