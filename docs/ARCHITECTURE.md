# LaptopInspectorPro Architecture

LaptopInspectorPro is a modular PowerShell diagnostic toolkit for inspecting Windows laptops.

## Runtime flow

1. `LaptopInspector.ps1` loads configuration and modules.
2. Each module exposes one `Get-LIP*` function and returns structured objects.
3. The main controller aggregates results.
4. `Score.ps1` calculates component and overall health scores.
5. `Report.ps1` can export TXT, JSON, and HTML reports.

## Design rules

- Modules should not print directly during collection; return objects instead.
- Hardware queries should fail gracefully when Windows does not expose a value.
- No administrator privileges are required for basic inspection.
- Reports contain collected data only; no credentials or secrets should be collected.
