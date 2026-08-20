function Get-LIPPortsInfo {
    try { @((Get-PnpDevice -PresentOnly -ErrorAction Stop) | Where-Object {$_.Class -in @('USB','Bluetooth','Ports')} | Select-Object -First 100 | ForEach-Object { [pscustomobject]@{Status=$_.Status; Class=$_.Class; Name=$_.FriendlyName; InstanceId=$_.InstanceId} }) } catch { [pscustomobject]@{Status='Unavailable';Error=$_.Exception.Message} }
}
