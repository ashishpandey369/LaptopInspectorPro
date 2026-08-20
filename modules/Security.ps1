function Get-LIPSecurityInfo {
    try {
        $secureBoot='Unknown'; try {$secureBoot=Confirm-SecureBootUEFI -ErrorAction Stop}catch{}
        $tpm='Unknown'; try {$tpm=(Get-Tpm -ErrorAction Stop).TpmPresent}catch{}
        $fw=Get-NetFirewallProfile -ErrorAction SilentlyContinue
        [pscustomobject]@{ Status='OK'; SecureBoot=$secureBoot; TPM=$tpm; FirewallEnabled=(($fw|Where-Object {$_.Enabled -eq $false}).Count -eq 0); DefenderAvailable=[bool](Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) }
    } catch { [pscustomobject]@{ Status='Unavailable'; Error=$_.Exception.Message } }
}
