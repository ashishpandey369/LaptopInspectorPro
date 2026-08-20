function Get-LIPCPUInfo {
    try {
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        [pscustomobject]@{
            Status='OK'; Name=$cpu.Name; Manufacturer=$cpu.Manufacturer; Cores=$cpu.NumberOfCores
            LogicalProcessors=$cpu.NumberOfLogicalProcessors; MaxClockMHz=$cpu.MaxClockSpeed
            CurrentClockMHz=$cpu.CurrentClockSpeed; LoadPercent=$cpu.LoadPercentage
            Architecture=$cpu.AddressWidth
        }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
