# 🛠️ Product Process & Current Limits Setup Guide

This document explains how to configure EOL process routing, limit voltages, cable verifications, and transducer current draw limits on a per-product-range basis.

All of these parameters are managed dynamically in the centralized SQLite database:
* **SQLite Database Path:** `C:\ProgramData\Senstronics\OffsetRig\offset_setup.db`
* **Target Table:** `product_ranges`

---

## 🗄️ 1. Product Ranges Table (`product_ranges`)

Instead of hardcoding product range exceptions in the source code or using legacy flat files (`non-standard_processes.txt` and `current_draw.txt`), all product parameters are consolidated into the `product_ranges` table.

### Schema:
```sql
CREATE TABLE product_ranges (
    prefix TEXT PRIMARY KEY,
    process_name TEXT NOT NULL,
    limit_voltage REAL DEFAULT 10.0,
    require_verification INTEGER DEFAULT 0,
    current_draw_lower REAL,
    current_draw_upper REAL
);
```

### Column Descriptions:

| Column Name | Data Type | Default / Fallback | Description |
| :--- | :--- | :--- | :--- |
| **`prefix`** | TEXT | *N/A (Primary Key)* | The product range prefix matching the start of the scanned Works Order barcode (e.g., `UB`, `AM`, `UC`, `ST`). Supports variable prefix lengths. |
| **`process_name`** | TEXT | `"Standard"` | The target test flow route:<br>• **`PackOnly`**: Routes the sensor directly to the EOL voltage check (`PackTestOnly`), skipping multi-point calibration.<br>• **`Standard`**: Routes to the full test flow including multi-point calibration check. |
| **`limit_voltage`** | REAL | `10.0` | The EOL pass/fail limit in volts. |
| **`require_verification`**| INTEGER | `0` (False) | Dictates if the operator must verify setup parts before testing:<br>• **`1` (True)**: Forces operator to scan cable, select connector type, and verify board setup (e.g., `UC` range).<br>• **`0` (False)**: Skips verification scans entirely (e.g., `UB`, `AM`). |
| **`current_draw_lower`** | REAL | `2.0` (mA) | The lower current draw threshold in milliamperes. If set to `NULL` (database NULL), falls back to `2.0` mA. |
| **`current_draw_upper`** | REAL | `5.6` (mA) | The upper current draw threshold in milliamperes. If set to `NULL` (database NULL), falls back to `5.6` mA. |

---

## 🚀 2. Seeding & Database Tooling

You can seed or rebuild the database using the helper script:
```bash
python seed_database.py
```
This script automatically compiles configuration directories, reads legacy configurations from `Example Configurations/`, and populates `offset_setup.db` with the correct tables, column structures, and product range mappings.
