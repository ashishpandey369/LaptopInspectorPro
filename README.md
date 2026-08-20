# LaptopInspectorPro

Windows laptop diagnostic and health-assessment toolkit built with PowerShell.

## Current version

**v0.2.0 — Deep Diagnostics Foundation**

LaptopInspectorPro is designed to inspect a Windows laptop's hardware, software environment, health indicators, and security posture, then turn the results into a readable health score and reports.

## Features

### Hardware
- CPU information and current load
- GPU / display adapter detection
- RAM capacity and usage
- Physical disk detection
- Volume/storage usage
- Battery capacity health, wear and cycle count when exposed by Windows
- Display information
- Audio devices
- Camera devices
- Touch / digitizer detection
- Network adapters
- USB, Bluetooth and COM peripherals

### Deep diagnostics
- Physical storage health through `Get-PhysicalDisk`
- Storage reliability counters when supported
- Disk temperature / wear / power-on hours when exposed
- Plug-and-Play device problem detection
- Thermal-zone readings when Windows exposes ACPI data
- TPM / Secure Boot / firewall checks

### Scoring
The health engine combines component results into a weighted overall score from 0–100 and assigns a grade:

- **90–100:** Excellent
- **80–89:** Good
- **70–79:** Fair
- **60–69:** Needs Attention
- **Below 60:** Poor

The score is intentionally diagnostic rather than a benchmark score. Missing hardware telemetry is excluded rather than treated as a failure.

### Reports
Full inspections can generate:

- JSON — machine-readable complete results
- TXT — human-readable report
- HTML — browser-friendly report

## Run

Open PowerShell in the repository folder:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\LaptopInspector.ps1
```

### Quick mode

```powershell
.\LaptopInspector.ps1 -Mode Quick
```

### Full diagnostics

```powershell
.\LaptopInspector.ps1 -Mode Full
```

### Generate a full report

```powershell
.\LaptopInspector.ps1 -Mode Report
```

Or choose a report directory/path with `-ReportPath`.

## Architecture

```text
LaptopInspectorPro/
├── LaptopInspector.ps1       # application controller
├── config.json               # diagnostic/scoring configuration
├── modules/
│   ├── Audio.ps1
│   ├── Battery.ps1
│   ├── CPU.ps1
│   ├── Camera.ps1
│   ├── Disk.ps1
│   ├── Display.ps1
│   ├── Drivers.ps1
│   ├── GPU.ps1
│   ├── Network.ps1
│   ├── Ports.ps1
│   ├── RAM.ps1
│   ├── Report.ps1
│   ├── Score.ps1
│   ├── Security.ps1
│   ├── Storage.ps1
│   ├── StorageHealth.ps1
│   ├── System.ps1
│   ├── Thermals.ps1
│   ├── Touch.ps1
│   └── Windows.ps1
└── docs/
    └── ARCHITECTURE.md
```

## Design principles

1. **Read-only diagnostics first.** Inspection should not modify system configuration.
2. **Graceful degradation.** Hardware telemetry varies by laptop vendor and Windows edition; unavailable sensors are reported as unavailable.
3. **Modular collectors.** Each subsystem is isolated so it can be improved without rewriting the application controller.
4. **Machine-readable output.** Reports are structured so future UI and web dashboards can consume them.
5. **Explainable scoring.** Scores are component-based and weighted, not a mystery number.

## Roadmap

### v0.3
- SMART/NVMe diagnostics improvements
- Better battery telemetry
- Driver version inventory
- Windows Update health
- Device Manager problem details
- Improved thermal telemetry

### v0.4
- Used-laptop purchase assessment
- BUY / NEGOTIATE / SKIP recommendation
- Asking-price vs estimated-value workflow
- Stronger component-level scoring

### v0.5+
- Advanced benchmarks and safe stress tests
- Interactive HTML dashboard
- PDF reports
- Packaging and release automation

## License

MIT. See `LICENSE`.
