function Get-LIPBatteryInfo {
    try {
        $b=@(Get-CimInstance Win32_Battery)
        if(-not $b){ return [pscustomobject]@{ Status='NotPresent'; HealthPercent=$null; Note='No battery reported by Windows.' } }

        $design=$null; $full=$null; $cycle=$null
        try { $w=Get-CimInstance -Namespace root/wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1; $design=$w.DesignedCapacity } catch {}
        try { $f=Get-CimInstance -Namespace root/wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1; $full=$f.FullChargedCapacity } catch {}
        try { $c=Get-CimInstance -Namespace root/wmi -ClassName BatteryCycleCount -ErrorAction Stop | Select-Object -First 1; $cycle=$c.CycleCount } catch {}

        $health=if($design -and $full -and $design -gt 0){[math]::Round(($full/$design)*100,1)}else{$null}
        $wear=if($null -ne $health){[math]::Round([math]::Max(0,100-$health),1)}else{$null}
        $charge=($b|Measure-Object EstimatedChargeRemaining -Maximum).Maximum
        $status=($b|Select-Object -First 1).BatteryStatus
        $charging=($b | Where-Object {$_.BatteryStatus -in 6,7,8,9}).Count -gt 0

        [pscustomobject]@{
            Status='OK'
            HealthPercent=$health
            WearPercent=$wear
            DesignCapacitymWh=$design
            FullChargeCapacitymWh=$full
            ChargePercent=$charge
            Charging=$charging
            BatteryStatus=$status
            CycleCount=$cycle
            HealthGrade=if($null -eq $health){'Unknown'}elseif($health -ge 90){'Excellent'}elseif($health -ge 80){'Good'}elseif($health -ge 60){'Fair'}else{'Poor'}
            Note=if($null -eq $health){'Battery capacity data is not exposed by this device/driver.'}else{'Capacity health is calculated from designed vs full-charge capacity.'}
        }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
