# ⚙️ Configuration Guide (`offset_config.txt`)

This document explains all the configurable parameters supported by the Offset Rig Software. These parameters are parsed from the local configuration file **`offset_config.txt`**, which must be located in the same directory as the executable (`OffsetCheck.exe`).

If a parameter is not specified in the config file, the software automatically falls back to its built-in, backward-compatible default values.

---

## 📂 Configuration File Format
*   The config file is a simple line-based text file.
*   Each parameter must be specified on a new line using a comma-separated key-value format: `parameter_name, value`.
*   Lines starting with `#` or `;` are treated as comments and ignored.
*   Spaces around keys and values are automatically trimmed.
*   Keys are case-insensitive.

---

## 🎛️ 1. Hardware & Calibration Settings

These parameters calibrate timing, temperature compensation, and power supply voltages for individual physical test rigs.

| Parameter Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| **`psu_visa_id`** | String | `9103875` | The VISA resource address string for the Keithley 2230 programmable power supply unit (e.g. `USB0::0x05E6::0x2230::<psu_visa_id>::INSTR`). |
| **`temp_cal_offset`** | Double | `-5` | Temperature calibration offset in °C added to the temperature sensor reading to match reference standards. |
| **`relay_delay`** | Long | `0` | Delay in milliseconds executed during DMM relay switching cycles to allow physical relay contacts to settle before readings. |
| **`psu_ch2_factor`** | Double | `0.986` | Calibration scaling multiplier for PSU Channel 2 (Transducer supply voltage) to compensate for wiring resistance and voltage drops. |
| **`psu_ch3_factor`** | Double | `0.9645` | Calibration scaling multiplier for PSU Channel 3 (Switch Input voltage) to compensate for wiring resistance and voltage drops. |

**Example:**
```text
psu_visa_id, 9203519
temp_cal_offset, -9
relay_delay, 50
psu_ch2_factor, 0.985
psu_ch3_factor, 0.965
```

---

## 🗄️ 2. Database & Resource Paths

Paths to the local text databases containing product categories, union codes, board mapping logic, and cable types.

| Parameter Name | Default Value | Description |
| :--- | :--- | :--- |
| **`board_type_path`** | `C:\offset setup files\Board Type.txt` | Path to the text database mapping circuit board identifiers to pinout relays. |
| **`union_list_path`** | `C:\offset setup files\union list.txt` | Path to the list of supported union mechanical fittings and their calibration IDs. |
| **`connector_type_path`**| `C:\offset setup files\connector type.txt` | Path to the connector list defining active pins. |
| **`colour_list_path`** | `C:\offset setup files\Colour list.txt` | Path to the wire colour code database. |
| **`cable_list_path`** | `C:\offset setup files\cable list.txt` | Path to the active cable assembly part numbers. |
| **`cable_usage_path`** | `C:\offset setup files\Cable Usage.txt` | Path to the rolling cable cycle counter database. |
| **`rig_type_path`** | `C:\offset setup files\Rig Type.txt` | Path to the rig type classification file (defines rig-specific limits). |
| **`non_standard_processes_path`** | `C:\offset setup files\non-standard_processes.txt` | Path to the database file mapping product prefixes to non-standard EOL test routes, limits, and verification requirements. |

**Example:**
```text
board_type_path, D:\RigSetup\Board Type.txt
cable_usage_path, C:\RigData\Cable Usage.txt
non_standard_processes_path, D:\RigSetup\non-standard_processes.txt
```

---

## 📊 3. Output, Logs & Network Paths

Paths used for storing diagnostic telemetry, Excel test certificates, database queries, and label printing scripts.

| Parameter Name | Default Value | Description |
| :--- | :--- | :--- |
| **`results_path`** | `\\USVR8\Results\Production\Offset Check Results\` | Primary network directory where output Excel spreadsheets (`WorksOrder.xls`) are archived. |
| **`local_results_path`**| `C:\My documents\Offset Check Results\` | Fallback local directory used to save Excel reports if the network share is offline. |
| **`work_order_path`** | `M:\paulseal.txt` | Network path to the shared works order queue file managed by upstream production planning. |
| **`label_print_input_path`**| `M:\system\load\Vborders.txt` | Target buffer file containing print codes generated for completed sensor labels. |
| **`label_print_batch_path`**| `C:\liveorders\PrintLabel.bat` | Batch script triggered by the EOL check app to physically print barcodes. |

**Example:**
```text
results_path, \\BACKUPSERVER\TestResults\
work_order_path, C:\OfflineBackup\paulseal.txt
```

---

## 🔊 4. Sounds & Updates

| Parameter Name | Default Value | Description |
| :--- | :--- | :--- |
| **`sound_complete_path`**| `C:\offset setup files\complete.wav` | Path to the `.wav` audio file played when a sensor passes EOL calibration. |
| **`sound_failed_path`** | `C:\offset setup files\failed.wav` | Path to the `.wav` audio file played when a sensor fails calibration. |
| **`update_network_path`**| `Q:\SENSTRONICS\CONTROLLED MACHINE SOFTWARE\Offset Rig Software VB` | Network directory monitored on clean-down to check for and fetch newer builds of `OffsetCheck.exe`. |

**Example:**
```text
sound_complete_path, C:\sounds\success.wav
sound_failed_path, C:\sounds\error.wav
```

---

## 💻 5. Simulation & Developer Mode

Used to run the software on a development PC without any physical measurement hardware connected.

| Parameter Name | Values | Default Value | Description |
| :--- | :--- | :--- | :--- |
| **`dev_mode`** | `1`, `true`, `0`, `false` | `false` | Set to `1` or `true` to enable Developer Mode. This mocks all GPIB, serial, digital I/O, and PSU interfaces. Developers can press `F2` on the form to run a simulated calibration cycle. |

**Example:**
```text
dev_mode, 1
```
