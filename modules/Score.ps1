function Get-LIPHealthScore {
    param([Parameter(Mandatory)]$Results)

    $scores=[ordered]@{}

    $cpu=$Results.'Get-LIPCPUInfo'
    if($cpu.Status -eq 'OK'){
        $load=if($null -ne $cpu.LoadPercent){$cpu.LoadPercent}else{50}
        $scores.CPU=[math]::Round([math]::Max(50,[math]::Min(100,100-($load*0.35))),1)
    }

    $gpu=$Results.'Get-LIPGPUInfo'
    if($gpu){$scores.GPU=90}

    $ram=$Results.'Get-LIPRAMInfo'
    if($ram.Status -eq 'OK'){
        $used=if($null -ne $ram.UsedPercent){$ram.UsedPercent}else{50}
        $scores.RAM=[math]::Round([math]::Max(55,[math]::Min(100,100-($used*0.35))),1)
    }

    $bat=$Results.'Get-LIPBatteryInfo'
    if($null -ne $bat.HealthPercent){$scores.Battery=[math]::Min(100,[math]::Max(0,$bat.HealthPercent))}
    elseif($bat.Status -eq 'NotPresent'){$scores.Battery=$null}

    $storage=$Results.'Get-LIPStorageInfo'
    if($storage){
        $fullVolumes=@($storage|Where-Object {$null -ne $_.UsedPercent -and $_.UsedPercent -ge 95}).Count
        $scores.Storage=if($fullVolumes){60}else{90}
    }

    $storageHealth=$Results.'Get-LIPStorageHealthInfo'
    if($storageHealth.Status -eq 'OK' -and $storageHealth.Disks.Count -gt 0){
        $bad=@($storageHealth.Disks|Where-Object {$_.HealthStatus -and $_.HealthStatus -notin @('Healthy','OK')}).Count
        if($bad -gt 0){$scores.Storage=[math]::Min($scores.Storage,55)}
        $wear=@($storageHealth.Disks|Where-Object {$null -ne $_.WearPercent}|ForEach-Object {[double]$_.WearPercent})
        if($wear.Count -gt 0 -and (($wear|Measure-Object -Average).Average -gt 20)){$scores.Storage=[math]::Min($scores.Storage,75)}
    }

    $display=$Results.'Get-LIPDisplayInfo'; if($display){$scores.Display=90}
    $network=$Results.'Get-LIPNetworkInfo'; if($network){$scores.Network=90}

    $security=$Results.'Get-LIPSecurityInfo'
    if($security.Status -eq 'OK'){$scores.Security=if($security.FirewallEnabled -and $security.TPM -ne $false){95}else{70}}

    $drivers=$Results.'Get-LIPDriverSummary'
    if($drivers.Status -eq 'OK'){
        $scores.Drivers=if($drivers.ProblemCount -eq 0){95}elseif($drivers.ProblemCount -le 2){75}else{50}
    }

    $thermal=$Results.'Get-LIPThermalInfo'
    if($thermal.Status -eq 'OK' -and $thermal.Zones.Count -gt 0){
        $temps=@($thermal.Zones|Where-Object {$null -ne $_.TemperatureC}|ForEach-Object {[double]$_.TemperatureC})
        if($temps.Count -gt 0){
            $maxTemp=($temps|Measure-Object -Maximum).Maximum
            $scores.Thermals=if($maxTemp -lt 70){95}elseif($maxTemp -lt 85){80}elseif($maxTemp -lt 95){65}else{45}
        }
    }

    $scores.System=90

    $weights=@{CPU=15;GPU=12;RAM=10;Storage=18;Battery=15;Display=8;Network=5;Security=8;Drivers=5;Thermals=4;System=5}
    $weighted=0.0; $weightUsed=0.0
    foreach($k in $scores.Keys){
        if($null -ne $scores[$k] -and $weights.ContainsKey($k)){
            $weighted += $scores[$k]*$weights[$k]
            $weightUsed += $weights[$k]
        }
    }
    $overall=if($weightUsed){[math]::Round($weighted/$weightUsed,1)}else{0}
    $grade=if($overall -ge 90){'Excellent'}elseif($overall -ge 80){'Good'}elseif($overall -ge 70){'Fair'}elseif($overall -ge 60){'Needs Attention'}else{'Poor'}

    [pscustomobject]@{ Overall=$overall; Grade=$grade; Components=[pscustomobject]$scores }
}
