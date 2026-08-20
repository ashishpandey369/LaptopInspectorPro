function Get-LIPDiskInfo {
    try {
        $disks=@(Get-CimInstance Win32_DiskDrive)
        @($disks | ForEach-Object { [pscustomobject]@{ Status='OK'; Model=$_.Model; Interface=$_.InterfaceType; SizeGB=[math]::Round($_.Size/1GB,2); MediaType=$_.MediaType; SerialNumber=$_.SerialNumber } })
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
