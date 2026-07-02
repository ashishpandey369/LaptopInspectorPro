
function Get-WindowsInfo {
 $lic=Get-CimInstance SoftwareLicensingProduct | Where-Object {$_.LicenseStatus -eq 1 -and $_.PartialProductKey}
 if($lic){Write-Host "Windows    : Activated"} else {Write-Host "Windows    : Not Activated"}
}
