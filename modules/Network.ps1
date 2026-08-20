function Get-LIPNetworkInfo {
    try {
        $a=@(Get-NetAdapter -Physical -ErrorAction Stop | Where-Object Status -ne 'Disabled')
        @($a | ForEach-Object { $ip=Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Select-Object -First 1; [pscustomobject]@{ Status='OK'; Name=$_.Name; Interface=$_.InterfaceDescription; State=$_.Status; LinkSpeed=$_.LinkSpeed; MAC=$_.MacAddress; IPv4=$ip.IPAddress } })
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
