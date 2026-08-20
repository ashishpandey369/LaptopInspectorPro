function Get-LIPAudioInfo {
    try { @((Get-CimInstance Win32_SoundDevice) | ForEach-Object { [pscustomobject]@{Status='OK'; Name=$_.Name; Manufacturer=$_.Manufacturer; StatusText=$_.Status} }) } catch { [pscustomobject]@{Status='Unavailable';Error=$_.Exception.Message} }
}
