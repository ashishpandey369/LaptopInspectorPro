function Get-LIPTouchInfo {
    try { $d=@(Get-PnpDevice -PresentOnly -ErrorAction Stop | Where-Object {$_.Class -match 'HID' -or $_.FriendlyName -match 'Touch|Digitizer'}); [pscustomobject]@{Status='OK';Detected=($d.Count -gt 0);Devices=$d.Count;Names=($d.FriendlyName -join '; ')} } catch { [pscustomobject]@{Status='Unavailable';Error=$_.Exception.Message} }
}
