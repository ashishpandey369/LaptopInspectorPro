function Get-LIPSystemInfo {
    try {
        $cs=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS
        [pscustomobject]@{ Status='OK'; Manufacturer=$cs.Manufacturer; Model=$cs.Model; SerialNumber=$bios.SerialNumber; RAMGB=[math]::Round($cs.TotalPhysicalMemory/1GB,2); Username=$cs.UserName; Domain=$cs.Domain }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
