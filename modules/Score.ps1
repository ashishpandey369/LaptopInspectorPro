function Get-LIPHealthScore {
    param([Parameter(Mandatory)]$Results)
    $scores=[ordered]@{}
    $cpu=$Results.Get-LIPCPUInfo; if($cpu.Status -eq 'OK'){ $scores.CPU=if($cpu.LoadPercent -lt 70){90}else{75} }
    $ram=$Results.Get-LIPRAMInfo; if($ram.Status -eq 'OK'){ $scores.RAM=if($ram.UsedPercent -lt 75){90}else{70} }
    $bat=$Results.Get-LIPBatteryInfo; if($bat.HealthPercent){$scores.Battery=[math]::Min(100,[math]::Max(0,$bat.HealthPercent))}elseif($bat.Status -eq 'NotPresent'){$scores.Battery=$null}
    $storage=$Results.Get-LIPStorageInfo; if($storage){$scores.Storage=if(@($storage|Where-Object UsedPercent -ge 95).Count){60}else{90}}
    $display=$Results.Get-LIPDisplayInfo; if($display){$scores.Display=90}
    $security=$Results.Get-LIPSecurityInfo; if($security.Status -eq 'OK'){$scores.Security=if($security.FirewallEnabled -and $security.TPM -ne $false){95}else{70}}
    $weights=@{CPU=15;GPU=15;RAM=10;Storage=15;Battery=15;Display=10;Network=5;Security=10;System=5}
    $weighted=0.0; $weightUsed=0.0
    foreach($k in $scores.Keys){if($null -ne $scores[$k] -and $weights.ContainsKey($k)){$weighted += $scores[$k]*$weights[$k];$weightUsed += $weights[$k]}}
    $overall=if($weightUsed){[math]::Round($weighted/$weightUsed,1)}else{0}
    [pscustomobject]@{ Overall=$overall; Grade=if($overall -ge 90){'Excellent'}elseif($overall -ge 80){'Good'}elseif($overall -ge 70){'Fair'}else{'Needs Attention'}; Components=[pscustomobject]$scores }
}
