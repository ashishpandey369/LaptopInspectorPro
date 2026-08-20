# LaptopInspectorPro

Windows laptop diagnostic and health-assessment toolkit built with PowerShell.

## Download and Run — Recommended for Users

You do **not** need to install PowerShell development tools or manually run the source code.

### 1. Download the project

**[⬇️ Download LaptopInspectorPro ZIP](https://github.com/ashishpandey369/LaptopInspectorPro/archive/refs/heads/main.zip)**

Download the ZIP, then extract it anywhere on your Windows PC.

### 2. Start LaptopInspectorPro

Open the extracted folder and find:

```text
Run_LaptopInspectorPro_AsAdmin.bat
```

**Right-click `Run_LaptopInspectorPro_AsAdmin.bat` → Run as administrator.**

The launcher automatically requests Administrator privileges if required and starts LaptopInspectorPro.

### 3. Choose what you want to do

```text
1. Inspection
2. Purchasing
3. Exit
```

**Inspection** performs the complete laptop diagnostic and shows hardware information, health indicators, component scores, and the overall health score. It does not show purchasing recommendations.

**Purchasing** performs the inspection and then asks for the laptop's asking price before showing the purchase assessment.

> **Important:** Run the launcher as Administrator for the most complete Windows hardware, device, security, and system information available on the machine.

---

## Current version

**v0.4.0 — Inspection & Purchase Assessment**

LaptopInspectorPro inspects a Windows laptop's hardware, software environment, health indicators, and security posture, then turns the results into readable component health scores and reports.

## Features

### Hardware
- CPU information and current load
- GPU / display adapter detection
- RAM capacity, modules, speed, and usage
- Physical disk detection
- Volume/storage usage
- Battery capacity health, wear and cycle count when exposed by Windows
- Display information
- Audio devices
- Camera devices
- Touch / digitizer detection
- Network adapters and link information
- USB, Bluetooth and COM peripherals

### Deep diagnostics
- Physical storage health through Windows storage APIs
- Storage reliability counters when supported
- Disk temperature / wear / power-on hours when exposed
- Plug-and-Play device problem detection
- Thermal-zone readings when Windows exposes ACPI data
- TPM / Secure Boot / firewall checks
- Driver health summary

### Inspection
Inspection mode is strictly diagnostic. It shows:

- Complete inspection summary
- Overall health score
- Individual component scores
- System and Windows information
- CPU, GPU, RAM and storage details
- Battery details including cycle count when available
- Storage health details
- Display, audio and camera details
- Network and device details
- Security and driver health
- Thermal information

After the summary, you can choose **View each result** to open detailed information for every subsystem.

Inspection does **not** show BUY, NEGOTIATE, SKIP, asking-price, or fair-value results.

### Purchasing
Purchasing is a separate workflow. It asks for the laptop's asking price and combines that price with the inspection results to provide:

- Overall health
- Risk flags
- BUY / NEGOTIATE / SKIP recommendation
- Price assessment

The fair-value calculation is an inspection heuristic, not a live market-price lookup.

### Scoring
The health engine combines component results into a weighted overall score from 0–100 and assigns a grade:

- **90–100:** Excellent
- **80–89:** Good
- **70–79:** Fair
- **60–69:** Needs Attention
- **Below 60:** Poor

The score is diagnostic rather than a benchmark score. Missing hardware telemetry is excluded rather than automatically treated as a failure.

### Reports
Full inspections can generate:

- JSON — machine-readable complete results
- TXT — human-readable report
- HTML — browser-friendly report

## Developer Run

For development or testing, open PowerShell in the repository folder:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\LaptopInspector.ps1
```

### Inspection mode

```powershell
.\LaptopInspector.ps1 -Mode Inspection
```

### Purchasing mode

```powershell
.\LaptopInspector.ps1 -Mode Purchase -AskingPriceINR 28000
```

### Generate a report

```powershell
.\LaptopInspector.ps1 -Mode Report
```

## Architecture

```text
LaptopInspectorPro/
├── LaptopInspector.ps1
├── Run_LaptopInspectorPro_AsAdmin.bat
├── config.json
├── LICENSE
├── README.md
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
│   ├── Purchase.ps1
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

## License

LaptopInspectorPro is licensed under the MIT License.

See [`LICENSE`](LICENSE) for the full license text.
