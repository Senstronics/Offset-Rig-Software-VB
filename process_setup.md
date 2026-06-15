# 🛠️ Product Process & current limits Setup Guide

This document explains how to configure EOL process routing, limit voltages, cable verifications, and transducer current draw limits on a per-product-range basis. 

Rather than hardcoding product range exceptions in the source code, these parameters are managed dynamically via two lookup files:
1. **`non-standard_processes.txt`** — Configures EOL routing pathways, voltage limits, and component scanning requirements.
2. **`current_draw.txt`** — Overrides default current draw measurement acceptance windows.

---

## 📄 1. Non-Standard Processes Routing (`non-standard_processes.txt`)

This file routes specific product ranges to non-standard EOL check routines (e.g., bypassing full multi-point pressure calibration in favor of a single offset voltage verification).

### File Location & Overrides
* **Default Path:** `C:\offset setup files\non-standard_processes.txt`
* **Custom Path Override:** Can be configured in `offset_config.txt` using the `non_standard_processes_path` parameter.

### File Format
* Standard comma-separated values (CSV) format.
* Lines starting with `#` or `;` are treated as comments and ignored.
* **Columns:** `Prefix,ProcessName,LimitVoltage,RequireVerification`

### Column Descriptions

| Column # | Parameter Name | Type | Description |
| :--- | :--- | :--- | :--- |
| 1 | **`Prefix`** | String | The works order product prefix matching the start of the scanned Works Order barcode (e.g. `UB`, `AM`, `UC`). Matching is case-insensitive and supports variable prefix lengths. |
| 2 | **`ProcessName`** | String | The target test flow route. Currently supported process routes:<br>• **`PackOnly`**: Routes the sensor directly to the EOL voltage check (`PackTestOnly`), skipping multi-point calibration. |
| 3 | **`LimitVoltage`** | Double | The EOL pass/fail window limit in millivolts (e.g. `12` or `10`). If set to `0` or omitted, defaults to `10`. |
| 4 | **`RequireVerification`**| Boolean | Dictates if the operator must verify setup parts before testing:<br>• **`1` (True)**: Forces operator to scan cable, select connector type, and verify board setup (e.g. `UC` range).<br>• **`0` (False)**: Skips verification scans entirely (e.g. `UB`, `AM`). |

### Default Production Configuration
```text
# Product range prefixes, processes, and parameters
# Format: Prefix,ProcessName,LimitVoltage,RequireVerification
UB,PackOnly,12,0
AM,PackOnly,12,0
ST,PackOnly,10,0
UC,PackOnly,10,1
Z0,PackOnly,10,0
```

---

## 🔌 2. Dynamic Current Draw Limits (`current_draw.txt`)

During calibration checks, the software measures the sensor's transducer supply current draw (in mA) to verify internal electronics are within bounds.

### File Location
* Must be placed in **the same directory as the executable file** (`OffsetCheck.exe`).
* The path cannot be changed via `offset_config.txt`.

### File Format
* Comma-separated values (CSV) format.
* Lines starting with `#` or `;` are comments and ignored.
* **Columns:** `ProductRange,LowerLimit,UpperLimit`

### Column Descriptions

| Column # | Parameter Name | Type | Description |
| :--- | :--- | :--- | :--- |
| 1 | **`ProductRange`** | String | The 2-character product range prefix extracted from the Works Order (e.g. `UB`, `AM`, `UC`). |
| 2 | **`LowerLimit`** | Double | Lower current draw threshold limit in milliamperes (mA). |
| 3 | **`UpperLimit`** | Double | Upper current draw threshold limit in milliamperes (mA). |

*If a product range is not found in this file, the software automatically falls back to default limits of **`2.0` mA (Lower)** and **`5.6` mA (Upper)**.*

### Example Configuration
```text
# ProductRange, LowerLimit(mA), UpperLimit(mA)
UB,1.8,5.4
AM,1.8,5.4
UC,2.2,6.0
```
