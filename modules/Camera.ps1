function Get-LIPCameraInfo {
    try { @((Get-PnpDevice -Class Camera -ErrorAction Stop) | ForEach-Object { [pscustomobject]@{Status=if($_.Status -eq 'OK'){'OK'}else{'Attention'}; Name=$_.FriendlyName; State=$_.Status; InstanceId=$_.InstanceId} }) } catch { [pscustomobject]@{Status='Unavailable';Error=$_.Exception.Message} }
}
