function Get-LIPBatteryInfo {
    try {
        $b=@(Get-CimInstance Win32_Battery)
        if(-not $b){ return [pscustomobject]@{ Status='NotPresent'; HealthPercent=$null; Note='No battery reported by Windows.' } }
        $design=$null; $full=$null
        try { $w=Get-CimInstance -Namespace root/wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1; $design=$w.DesignedCapacity } catch {}
        try { $f=Get-CimInstance -Namespace root/wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1; $full=$f.FullChargedCapacity } catch {}
        $health=if($design -and $full){[math]::Round(($full/$design)*100,1)}else{$null}
        [pscustomobject]@{ Status='OK'; HealthPercent=$health; DesignCapacitymWh=$design; FullChargeCapacitymWh=$full; ChargePercent=($b|Measure-Object EstimatedChargeRemaining -Maximum).Maximum; Charging=($b|Where-Object {$_.BatteryStatus -in 6,7,8,9}) -ne $null; BatteryStatus=($b|Select-Object -First 1 -ExpandProperty BatteryStatus) }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
