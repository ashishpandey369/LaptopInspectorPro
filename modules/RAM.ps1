function Get-LIPRAMInfo {
    try {
        $sticks = @(Get-CimInstance Win32_PhysicalMemory)
        $total = ($sticks | Measure-Object Capacity -Sum).Sum
        $os = Get-CimInstance Win32_OperatingSystem
        [pscustomobject]@{
            Status='OK'; InstalledGB=[math]::Round($total/1GB,2); UsableGB=[math]::Round($os.TotalVisibleMemorySize/1MB,2)
            FreeGB=[math]::Round($os.FreePhysicalMemory/1MB,2); UsedPercent=[math]::Round((1-($os.FreePhysicalMemory/$os.TotalVisibleMemorySize))*100,1)
            Modules=$sticks.Count; Type=($sticks | Select-Object -First 1 -ExpandProperty SMBIOSMemoryType)
            SpeedMTs=($sticks | Measure-Object Speed -Maximum).Maximum
        }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
