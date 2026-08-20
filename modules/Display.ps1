function Get-LIPDisplayInfo {
    try {
        $m=@(Get-CimInstance Win32_VideoController | Where-Object {$_.CurrentHorizontalResolution})
        @($m | ForEach-Object { [pscustomobject]@{ Status='OK'; Adapter=$_.Name; Resolution="$($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution)"; RefreshRate=$_.CurrentRefreshRate; Driver=$_.DriverVersion; PNPDeviceID=$_.PNPDeviceID } })
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
