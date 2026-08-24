function Get-LIPPurchaseAssessment {
    param(
        [Parameter(Mandatory)]$Results
    )

    $score = if (Get-Command Get-LIPHealthScore -ErrorAction SilentlyContinue) { Get-LIPHealthScore -Results $Results } else { $null }
    $overall = if ($score) { [double]$score.Overall } else { 0 }

    $flags = [System.Collections.Generic.List[string]]::new()
    $battery = $Results.'Get-LIPBatteryInfo'
    if ($battery.HealthPercent -and $battery.HealthPercent -lt 70) { $flags.Add('Battery health is below 70%.') }
    $drivers = $Results.'Get-LIPDriverSummary'
    if ($drivers.ProblemCount -gt 0) { $flags.Add("$($drivers.ProblemCount) device/driver problem(s) detected.") }
    $storage = $Results.'Get-LIPStorageHealthInfo'
    if (@($storage | Where-Object { $_.Health -eq 'Warning' -or $_.Health -eq 'Critical' }).Count -gt 0) { $flags.Add('Storage health requires attention.') }
    $thermal = $Results.'Get-LIPThermalInfo'
    if (@($thermal | Where-Object { $_.Status -eq 'Warning' }).Count -gt 0) { $flags.Add('Thermal telemetry reports a warning.') }

    # Purchase decision is based only on the inspection health score.
    # No asking price, fair-value, market-price, or negotiation calculation is used.
    $shouldBuy = $overall -ge 85
    $verdict = if ($shouldBuy) { 'BUY' } else { 'DO NOT BUY' }
    $confidence = if ($flags.Count -eq 0) { 'High' } elseif ($flags.Count -le 2) { 'Medium' } else { 'Low' }

    if ($shouldBuy) {
        $message = "BUY — The laptop passed the health assessment with an overall score of $overall/100."
    } else {
        $message = "DO NOT BUY — The laptop does not meet the required health threshold."
    }

    [pscustomobject]@{
        OverallScore = $overall
        ShouldBuy = $shouldBuy
        Verdict = $verdict
        Confidence = $confidence
        RecommendationMessage = $message
        RiskFlags = @($flags)
    }
}
