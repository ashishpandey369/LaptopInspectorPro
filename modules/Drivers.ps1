function Get-LIPDriverHealthInfo {
    try {
        $devices = @(Get-CimInstance Win32_PnPEntity -ErrorAction Stop)
        $problems = @($devices | Where-Object { $null -ne $_.ConfigManagerErrorCode -and $_.ConfigManagerErrorCode -ne 0 } | ForEach-Object {
            [pscustomobject]@{
                Name = $_.Name
                DeviceId = $_.PNPDeviceID
                ErrorCode = $_.ConfigManagerErrorCode
                Status = $_.Status
                Manufacturer = $_.Manufacturer
            }
        })
        [pscustomobject]@{
            Status='OK'
            DeviceCount=$devices.Count
            ProblemCount=$problems.Count
            ProblemDevices=$problems
        }
    } catch {
        [pscustomobject]@{Status='Unavailable';Error=$_.Exception.Message}
    }
}

function Get-LIPDriverSummary {
    $result = Get-LIPDriverHealthInfo
    [pscustomobject]@{
        Status = $result.Status
        DeviceCount = $result.DeviceCount
        ProblemCount = $result.ProblemCount
        Health = if($result.Status -ne 'OK'){'Unknown'}elseif($result.ProblemCount -eq 0){'Good'}elseif($result.ProblemCount -le 2){'Attention'}else{'Problems Detected'}
        ProblemDevices = $result.ProblemDevices
    }
}
