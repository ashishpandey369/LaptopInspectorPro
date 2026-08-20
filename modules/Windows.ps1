function Get-LIPWindowsInfo {
    try {
        $os=Get-CimInstance Win32_OperatingSystem
        [pscustomobject]@{ Status='OK'; Caption=$os.Caption; Version=$os.Version; Build=$os.BuildNumber; Architecture=$os.OSArchitecture; InstallDate=$os.InstallDate; LastBoot=$os.LastBootUpTime }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
