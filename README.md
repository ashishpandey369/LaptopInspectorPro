# LaptopInspectorPro

LaptopInspectorPro is a modular PowerShell toolkit for inspecting Windows laptops and producing a practical health assessment.

> Current release: **0.1.0 — Foundation + hardware inspection**

## What it does now

- Detects laptop manufacturer, model and BIOS information
- Reports Windows version and build
- Inspects CPU cores, threads, clocks and current load
- Detects GPUs, VRAM, drivers and display mode
- Reports installed/usable RAM and memory speed
- Lists physical disks and logical storage usage
- Estimates battery health when Windows exposes design/full-charge capacity
- Detects displays, audio devices, cameras, network adapters and common peripheral devices
- Checks Secure Boot, TPM and firewall state where available
- Calculates a first-pass component/overall health score
- Generates JSON, TXT and HTML inspection reports

## Run

Open PowerShell in the repository directory:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\LaptopInspector.ps1
```

Non-interactive modes:

```powershell
.\LaptopInspector.ps1 -Mode Quick
.\LaptopInspector.ps1 -Mode Full
.\LaptopInspector.ps1 -Mode Report
```

## Architecture

```text
LaptopInspector.ps1
        |
        +-- modules/CPU.ps1
        +-- modules/GPU.ps1
        +-- modules/RAM.ps1
        +-- modules/Disk.ps1
        +-- modules/Storage.ps1
        +-- modules/Battery.ps1
        +-- modules/Display.ps1
        +-- modules/Audio.ps1
        +-- modules/Camera.ps1
        +-- modules/Network.ps1
        +-- modules/Ports.ps1
        +-- modules/Touch.ps1
        +-- modules/Security.ps1
        +-- modules/System.ps1
        +-- modules/Windows.ps1
        |
        +-- Score.ps1
        +-- Report.ps1
        |
        +-- config.json
```

## Roadmap

### v0.2
- More robust storage/SMART health detection
- Better battery cycle and wear reporting
- Driver inventory and problem-device detection
- Better Wi-Fi and Bluetooth diagnostics
- Improved display/monitor information

### v0.3
- Hardware stress/benchmark hooks
- Thermal monitoring where supported
- Component scoring improvements
- Used-laptop price and Buy/Negotiate/Skip analysis

### v1.0
- Polished interactive interface
- Full HTML report dashboard
- PDF export
- Automated test suite
- Packaged release builds
- Complete documentation

## Safety and privacy

LaptopInspectorPro is intended for read-only inspection. It does not intentionally collect passwords, browser credentials, or other secrets. Some Windows hardware information requires administrator privileges or vendor-specific interfaces and may therefore be reported as unavailable.

## License

MIT License — see `LICENSE`.
