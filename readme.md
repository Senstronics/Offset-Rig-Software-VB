# 🛠️ Offset Rig Software VB

Welcome to the unified repository for the **End-of-Line (EOL) check software** running on the physical "Offset" calibration/test stations in **Unit 3**. 

This project represents the modernization, consolidation, and refactoring of legacy Visual Basic 6 (VB6) codebases migrated to the **twinBASIC** compiler ecosystem.

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
*   **🔌 Dynamic Current Draw Overrides:** Replaced duplicated hardcoded current limits with dynamic limits loaded from `current_draw.txt` on a per-product-range basis (e.g. `RT`, `XJ`, `XV`, `FT`, `XF`).
*   **🔋 AM Product Range Exceptions:** Added exception rules (including custom voltage thresholds and limits of ±12) for the new `"AM"` product line, mapping them dynamically to the existing `"UB"` product rules.
*   **📂 Dynamic File Parsing:** Replaced the legacy fixed-length loops (e.g. `For i = 1 To 150`) with modern `Do While Not EOF(FileHandle)` structures to allow configuration lists to grow dynamically without compilation limits.

---

## 🗺️ Roadmap & Backlog (Identified by Human Auditors)

We have identified several critical areas for improvement to be resolved in upcoming sprints:

### 🏷️ A. Version Control & Release Management
*   **The Issue:** Right now, versioning is arbitrary (indicated only by `"V34"` in the main form title and `"V34.1"` in the binary's filename).
*   **The Plan:** Remove hardcoded version strings from the UI titles and filenames. Hide the active version string inside a Help/About menu. Version identifiers will correspond exactly to the **Git repository tags** under which the binaries are compiled.

### 🧹 B. Code Smells & Refactoring
1.  **DMM Switching Redundancy (`DigitalMultimeterControl.bas`):** Many switching subroutines replicate identical commands and logic solely to send command strings to the multimeter. These will be abstracted into a single parameterized router command.
2.  **Overcomplicated Barcode Parsing (`Barcode.bas`):** The parsing engine for works order sheet barcodes is excessively complex and brittle. It will be refactored into a clean, pattern-matching regex/substring scanner.
3.  **Inefficient Load Checking (`OffsetCheck.bas`):** The `CheckLoad` routine features an inefficient and convoluted conversion logic that will be rewritten for clarity and speed.

### 🗺️ C. Hardcoded Product Process Variations
*   **The Issue:** Operators cannot easily tell which testing process a particular product range will follow because routing logic is hardcoded inside branching conditional statements.
*   **The Plan:** 
    *   Clearly define and document the possible EOL testing processes.
    *   Determine the most common test path and establish it as the default system behavior.
    *   Create a clean lookup dictionary of product range overrides to route non-standard products to their respective custom tests.
