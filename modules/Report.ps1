function Export-LIPReport {
    param([Parameter(Mandatory)]$Results,[string]$OutputPath='')
    if([string]::IsNullOrWhiteSpace($OutputPath)){ $OutputPath=Join-Path (Split-Path -Parent $PSScriptRoot) 'Reports' }
    if(-not [System.IO.Path]::GetExtension($OutputPath)){New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null; $base=Join-Path $OutputPath ("LaptopInspection_{0:yyyyMMdd_HHmmss}" -f (Get-Date))}else{$base=[System.IO.Path]::ChangeExtension($OutputPath,$null)}
    $dir=Split-Path -Parent $base; New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $score=if(Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue){Get-LIPHealthScore -Results $Results}else{$null}
    $payload=[pscustomobject]@{GeneratedAt=(Get-Date).ToString('o'); Results=$Results; HealthScore=$score}
    $payload | ConvertTo-Json -Depth 8 | Set-Content "$base.json" -Encoding UTF8
    $lines=@('LaptopInspectorPro Report',('Generated: '+$payload.GeneratedAt),'',('Overall Score: '+$score.Overall+' / 100'),('Grade: '+$score.Grade),'')
    foreach($p in $Results.PSObject.Properties){$lines += "[$($p.Name)]"; $lines += (($p.Value | Out-String).Trim()); $lines += ''}
    $lines | Set-Content "$base.txt" -Encoding UTF8
    $html=$payload | ConvertTo-Html -Title 'LaptopInspectorPro Report' -PreContent "<h1>LaptopInspectorPro</h1><p>Overall Score: $($score.Overall)/100 — $($score.Grade)</p>" | Out-String
    $html | Set-Content "$base.html" -Encoding UTF8
    Write-Host "Reports created: $base.json / $base.txt / $base.html" -ForegroundColor Green
    Get-Item "$base.json","$base.txt","$base.html"
}
