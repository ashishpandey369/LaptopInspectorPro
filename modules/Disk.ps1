
function Get-DiskInfo {
 Get-CimInstance Win32_DiskDrive | ForEach-Object{
  Write-Host ("Disk       : {0} ({1:N0} GB) Status:{2}" -f $_.Model,($_.Size/1GB),$_.Status)
 }
}
