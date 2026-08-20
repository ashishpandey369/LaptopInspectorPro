function Get-LIPStorageHealthInfo {
    try {
        $physical = @(Get-PhysicalDisk -ErrorAction Stop)
        $items = foreach ($disk in $physical) {
            $reliability = $null
            try { $reliability = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction Stop } catch {}
            [pscustomobject]@{
                FriendlyName = $disk.FriendlyName
                DeviceId = $disk.DeviceId
                MediaType = [string]$disk.MediaType
                BusType = [string]$disk.BusType
                HealthStatus = [string]$disk.HealthStatus
                OperationalStatus = (@($disk.OperationalStatus) -join ', ')
                SizeGB = if($disk.Size){[math]::Round($disk.Size / 1GB, 2)}else{$null}
                TemperatureC = if($reliability -and $reliability.Temperature){$reliability.Temperature}else{$null}
                WearPercent = if($reliability -and $null -ne $reliability.Wear){$reliability.Wear}else{$null}
                ReadErrors = if($reliability){$reliability.ReadErrorsTotal}else{$null}
                WriteErrors = if($reliability){$reliability.WriteErrorsTotal}else{$null}
                PowerOnHours = if($reliability){$reliability.PowerOnHours}else{$null}
                Source = 'Get-PhysicalDisk / StorageReliabilityCounter'
            }
        }
        if(-not $items){ return [pscustomobject]@{Status='Unavailable'; Note='No physical disks were returned by the Storage module.'} }
        [pscustomobject]@{Status='OK'; Disks=@($items)}
    } catch {
        [pscustomobject]@{Status='Unavailable'; Error=$_.Exception.Message; Note='Storage health counters are not available on every Windows edition or device.'}
    }
}
