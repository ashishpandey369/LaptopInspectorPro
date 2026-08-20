function Get-LIPThermalInfo {
    $zones = @()
    try {
        $raw = @(Get-CimInstance -Namespace root/wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop)
        $zones = @($raw | ForEach-Object {
            [pscustomobject]@{
                InstanceName = $_.InstanceName
                TemperatureC = [math]::Round((($_.CurrentTemperature / 10) - 273.15), 1)
                CriticalTripC = if($_.CriticalTripPoint){[math]::Round((($_.CriticalTripPoint / 10) - 273.15),1)}else{$null}
                Active = $_.Active
            }
        })
    } catch {}
    if($zones.Count -gt 0){
        return [pscustomobject]@{Status='OK';Zones=$zones;Source='ACPI thermal zones'}
    }
    [pscustomobject]@{Status='Unavailable';Zones=@();Note='Windows did not expose ACPI thermal-zone temperatures on this system. This is normal on many modern laptops.'}
}
