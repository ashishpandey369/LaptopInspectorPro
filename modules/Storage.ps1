function Get-LIPStorageInfo {
    try {
        $vol=@(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3")
        @($vol | ForEach-Object { [pscustomobject]@{ Status='OK'; Drive=$_.DeviceID; FileSystem=$_.FileSystem; SizeGB=[math]::Round($_.Size/1GB,2); FreeGB=[math]::Round($_.FreeSpace/1GB,2); UsedPercent=if($_.Size){[math]::Round((1-($_.FreeSpace/$_.Size))*100,1)}else{$null} } })
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
