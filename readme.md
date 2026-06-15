# 🛠️ Offset Rig Software VB

Welcome to the unified repository for the **End-of-Line (EOL) check software** running on the physical "Offset" test stations in **Unit 3**. 

This project represents the modernization, consolidation, and refactoring of legacy Visual Basic 6 (VB6) codebases migrated to the **twinBASIC** compiler ecosystem.

---

## 🚀 Quick Start for New Users & Developers

If you are new to the repository, setting up a developer workstation, or deploying to a physical testing rig, please follow these documentation guides:

> [!IMPORTANT]
> *   **[First-Time Developer Setup & Deployment Guide](deployment.md)** — Step-by-step instructions on setting up your environment, database files, and compiling/releasing the software.
> *   **[Rig Configuration Guide (offset_config.txt)](configuration.md)** — Detailed reference for all configurable parameters, VISA device IDs, local/network path overrides, and simulated Developer Mode controls.
> *   **[Product Process & Current Limits Setup Guide (process_setup.md)](process_setup.md)** — Detailed reference on routing non-standard products, setting offset limits, and configuring current draw overrides.

---

## 📌 Project Purpose & Genesis

### Origin
This project was born on **10/06/26**, forking the legacy EOL check systems.

### The Challenge
With the introduction of new products and changing quality verification standards, the EOL stations received a surge in feature requests. The legacy codebase was fragmented across separate folders for each station (Offset 1, Offset 2, Offset 3), resulting in duplicated code, hardcoded hardware variations, and severe maintainability issues.

### The Mission
The core goal of this project is two-fold:
1. **Unification:** Consolidate all physical testing stations into a **single, unified codebase** driven by configuration.
2. **Modernization:** Clean up legacy code smells, simplify data parsers, and restructure logic to prepare the software for future translation into modern language frameworks (e.g., Python or C#). Both human and AI auditors are utilized to target improvements.

---

## 🚀 Key Modernizations Achieved

*   **🎛️ Codebase Unification:** Consolidated three distinct, station-specific project directories into one repository. Station-specific hardware identifiers (VISA IDs), calibration constants, and timing delays have been abstracted into a single local config file: `offset_config.txt`.
*   **🔌 Dynamic Current Draw Overrides:** Replaced duplicated hardcoded current limits with dynamic limits loaded from `current_draw.txt` on a per-product-range basis.
*   **🗺️ Configuration-Driven Process Routing:** Replaced hardcoded EOL test routing rules (e.g. `PackOnly` checks) and custom voltage limit/verification overrides (like the special cases for `UB`, `AM`, and `UC`) with a fully dynamic configuration database file `non-standard_processes.txt`.
*   **📂 Dynamic File Parsing:** Replaced the legacy fixed-length loops with modern `Do While Not EOF(FileHandle)` structures.
*   **Option Explicit Directives:** Enforced strict variable declaration compilation checks across all key modules, resolving dozens of implicit type compiler warnings.
*   **Line of Best Fit Resistor Conversion:** Replaced the 1,000+ line hardcoded resistor mapping table with a single Line of Best Fit equation ($R^2 = 99.998\%$) in `CheckLoad()`.
*   **🎚️ Consolidated DMM Switching:** Consolidated over 80 repetitive switching card functions in `DigitalMultimeterControl.bas` and removed massive duplicate `If PinOutSwitch = ...` blocks in `OffsetCheck.bas`, routing all relays through a single parameterized `RouteDMM` function.
*   **Safe Excel COM Lifecycle:** Overhauled the Excel reporting parser to cleanly close workbooks and release reference counts in order, eliminating `excel.exe` process leaks.
*   **🌍 Configuration-Driven Paths:** Abstracted all local and network file paths into configuration parameters loaded from `offset_config.txt` with zero-config backward-compatible defaults.
*   **🐛 Scanner Logic Nesting Bug Fix:** Corrected the nesting structure in the interlock scanner inside [InputsOutputs.bas](file:///c:/Users/lewis.heslop/Downloads/Offset%20Rig%20Software%20VB/InputsOutputs.bas) to enable monitoring of all hardware input bits.
*   **🔒 Concurrency-Safe File Access:** Overhauled shared Excel sheet updates (`WorksOrder.xls`) and works order database scans (`paulseal.txt`) to implement interactive warning-based retry loops on failure. Configured network logging (`yyyymmdd.log`) to utilize silent retries with an automatic fallback to local backups to prevent data loss or operator interruption.
*   **🏷️ Automated Versioning & Network Updates:** Removed hardcoded version strings from window titles. Implemented a dynamic compile-time version constant `CompileVersion` inside [LogFile.bas](file:///C:/Users/lewis.heslop/Downloads/Offset%20Rig%20Software%20VB/LogFile.bas). Created a PowerShell Network Launcher (`launcher.bat` and `LaunchOffsetCheck.ps1`) to check the network release share (`Q:`) and copy down new builds. Added update checking to `ClearDownButton_Click` to close the app if an update is available. Automated Git tagging, changelog compilation, and deployment via `release.py`.
*   **🎛️ Configurable PSU Calibration Constants:** Moved station-dependent hardware calibration compensation factors out of `ControlPSU.bas` and into `offset_config.txt` (via `psu_ch2_factor` and `psu_ch3_factor` parameters) to allow rig-specific voltage settings.
*   **🧹 Robust Barcode Parsing Engine:** Overhauled the brittle, magic-index substring barcode parsing in `Barcode.bas` and `OffsetCheck.bas`, replacing it with a structured, verified barcode parsing engine that prevents false calibration runs.

---

## 🗺️ Roadmap & Backlog

Our focus is on the final consolidation phase to prepare the application for a future modernization effort:

*   **🗄️ Setup Databases Consolidation (Centralizing Configurations):** Consolidate the multiple separate text files currently used to store long-term rig databases (such as `Board Type.txt`, `union list.txt`, `connector type.txt`, `Colour list.txt`, and `cable list.txt`) into a single structured configuration or a shared SQLite database. Since these parameters are identical across all three physical Offset calibration stations, moving to a unified configuration source will simplify change management and ensure absolute data alignment across rigs.
*   **🚀 Future Modernization:** Restructure and clean the unified twinBASIC codebase to prepare the application for translation into modern language frameworks (e.g., Python or C#) on the horizon.
