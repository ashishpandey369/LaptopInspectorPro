# LaptopInspectorPro

> **A PowerShell-based Windows laptop inspection and purchase-decision toolkit.**
>
> Inspect the laptop. Understand its health. Get a clear **BUY / DO NOT BUY** decision.

LaptopInspectorPro helps you inspect a Windows laptop before buying it. It collects hardware, system, security, storage, battery, driver, and thermal information, converts the results into an explainable health score, and provides a simple purchase decision based on the inspection.

---

## 🚀 What LaptopInspectorPro Does

### 🔍 Inspection

Perform a complete diagnostic inspection and see CPU, GPU, RAM, storage, battery, display, network, device, security, driver and thermal information, along with component scores and an overall **0–100 health score**.

### 🛒 Purchasing

The purchasing workflow runs the inspection and provides:

- Overall health score
- **BUY / DO NOT BUY** flag
- Clear recommendation message
- Confidence level
- Detected inspection risks

The project deliberately **does not use an asking price, fair-value calculation, market-value estimate, price multiplier, or negotiation price**. The purchase decision is based entirely on the laptop's diagnostic health.

---

## 🧠 How the Purchase Decision Works

```text
Laptop Inspection
       ↓
Component Health Analysis
       ↓
Overall Health Score (0–100)
       ↓
Score ≥ 85 ?
   ┌───────┴───────┐
  YES             NO
   ↓               ↓
 BUY          DO NOT BUY
```

Example:

```text
================ PURCHASING ASSESSMENT ================
Overall health : 91/100
Decision       : BUY
Confidence     : High

BUY — The laptop passed the health assessment with an overall score of 91/100.
```

The tool intentionally keeps the final purchasing decision simple: **inspect the laptop, evaluate its health, and show whether it meets the BUY threshold.**

---

## 📊 Health Scoring

The health engine combines component results into a weighted overall score from **0–100**.

| Score | Grade |
|---:|---|
| 90–100 | Excellent |
| 80–89 | Good |
| 70–79 | Fair |
| 60–69 | Needs Attention |
| Below 60 | Poor |

The score is diagnostic, not a synthetic benchmark score. When Windows cannot expose a particular hardware metric, that metric can be excluded instead of automatically treating the laptop as failed.

---

## 🛠️ Diagnostics

### Hardware

- CPU information and current load
- GPU / display adapter detection
- RAM capacity, modules, speed and usage
- Physical disk detection
- Volume and storage usage
- Battery capacity health, wear and cycle count when exposed by Windows
- Display information
- Audio devices
- Camera devices
- Touch / digitizer detection
- Network adapters and link information
- USB, Bluetooth and COM peripherals

### Deep Diagnostics

- Physical storage health through Windows storage APIs
- Storage reliability counters when supported
- Disk temperature, wear and power-on hours when exposed
- Plug-and-Play device problem detection
- Thermal-zone readings when Windows exposes ACPI data
- TPM / Secure Boot / firewall checks
- Driver health summary

---

## 📥 Download and Run — Recommended for Users

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

### 3. Choose a workflow

```text
1. Inspection
2. Purchasing
3. Exit
```

> **Important:** Administrator access is recommended for the most complete hardware, device, security and system information available from Windows.

---

## 💻 Developer Run

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
.\LaptopInspector.ps1 -Mode Purchase
```

### Generate a report

```powershell
.\LaptopInspector.ps1 -Mode Report
```

---

## 📄 Reports

Full inspections can generate:

- **JSON** — machine-readable complete results
- **TXT** — human-readable report
- **HTML** — browser-friendly report

---

## 🏗️ Architecture

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

---

## 🎯 Design Principles

1. **Read-only diagnostics first** — Inspection should not modify system configuration.
2. **Graceful degradation** — Hardware telemetry varies by laptop vendor and Windows edition.
3. **Modular collectors** — Each subsystem is isolated so it can be improved independently.
4. **Machine-readable output** — Reports are structured for future UI and web dashboards.
5. **Explainable scoring** — The overall score comes from component-level health data.
6. **Honest purchase guidance** — The tool reports laptop health and gives a BUY / DO NOT BUY flag without pretending to know a market price.

---

## 📌 Current Version

**v0.4.0 — Inspection & Purchase Assessment**

LaptopInspectorPro is an evolving project focused on making second-hand Windows laptop inspection faster, clearer and more reliable.

---

## 📜 License

LaptopInspectorPro is licensed under the MIT License.

See [`LICENSE`](LICENSE) for the full license text.
