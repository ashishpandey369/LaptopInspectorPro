function Get-LIPPurchaseAssessment {
    param(
        [Parameter(Mandatory)]$Results,
        [Nullable[double]]$AskingPriceINR
    )

    $score = if (Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue) { Get-LIPHealthScore -Results $Results } else { $null }
    $overall = if ($score) { [double]$score.Overall } else { 0 }

    $flags = [System.Collections.Generic.List[string]]::new()
    $battery = $Results.'Get-LIPBatteryInfo'
    if ($battery.HealthPercent -and $battery.HealthPercent -lt 70) { $flags.Add('Battery health is below 70%.') }
    $drivers = $Results.'Get-LIPDriverHealthInfo'
    if ($drivers.ProblemCount -gt 0) { $flags.Add("$($drivers.ProblemCount) device/driver problem(s) detected.") }
    $storage = $Results.'Get-LIPStorageHealthInfo'
    if (@($storage | Where-Object { $_.Health -eq 'Warning' -or $_.Health -eq 'Critical' }).Count -gt 0) { $flags.Add('Storage health requires attention.') }
    $thermal = $Results.'Get-LIPThermalInfo'
    if (@($thermal | Where-Object { $_.Status -eq 'Warning' }).Count -gt 0) { $flags.Add('Thermal telemetry reports a warning.') }

    $verdict = if ($overall -ge 85) { 'BUY' } elseif ($overall -ge 70) { 'NEGOTIATE' } else { 'SKIP' }
    $confidence = if ($flags.Count -eq 0) { 'High' } elseif ($flags.Count -le 2) { 'Medium' } else { 'Low' }

    $fairValue = $null
    $priceVerdict = $null
    if ($AskingPriceINR -and $AskingPriceINR -gt 0) {
        # This is an inspection heuristic, not a market-price lookup.
        $multiplier = if ($overall -ge 90) { 1.00 } elseif ($overall -ge 80) { 0.90 } elseif ($overall -ge 70) { 0.78 } elseif ($overall -ge 60) { 0.65 } else { 0.50 }
        $fairValue = [math]::Round($AskingPriceINR * $multiplier, -2)
        $priceVerdict = if ($AskingPriceINR -le $fairValue) { 'GOOD_PRICE' } elseif ($AskingPriceINR -le ($fairValue * 1.10)) { 'NEGOTIATE_PRICE' } else { 'HIGH_PRICE' }
    }

    [pscustomobject]@{
        OverallScore = $overall
        Verdict = $verdict
        Confidence = $confidence
        AskingPriceINR = $AskingPriceINR
        EstimatedFairValueINR = $fairValue
        PriceVerdict = $priceVerdict
        RiskFlags = @($flags)
        Disclaimer = 'Fair value is a local heuristic based on inspection score; it is not a live market valuation.'
    }
}
