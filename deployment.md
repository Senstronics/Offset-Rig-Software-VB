# 🚀 Offset Rig Software Deployment Guide

This guide documents the setup, configuration, and release procedures for the unified **Offset Rig Software**.

---

## 📂 1. Path Agnosticism & Repository Location

**The repository is fully path-agnostic.** 
You can clone or copy this repository to **any directory** on your C: drive (e.g., `C:\Projects\OffsetRigSoftware`, `C:\Users\lewis.heslop\Downloads\`, etc.). 

All automation scripts (`release.py`, `redeploy.py`, and `sync_all_twinprojs.py`) calculate their directories dynamically relative to their own file locations. They do not rely on hardcoded repository paths.

---

## 💻 2. Developer Machine Setup (First-Time)

To set up a local developer machine for editing and simulating the software:

1. **Clone the Repository:**
   Clone the repository to any directory of your choice on your system.
2. **Install twinBASIC:**
   Download and open the twinBASIC IDE (`twinBASIC.exe`).
3. **Configure Local Simulation (Developer Mode):**
   To launch the software without physical rigs (DMM, PSU, camera, or IO cards connected):
   * Create or open `offset_config.txt` in the root of the repository.
   * Add the line:
     ```text
     dev_mode,1
     ```
   This mocks all instrument reads with passing telemetry and enables the **`F2`** keyboard shortcut to simulate interlock closures and trigger tests.

---

## 🖥️ 3. Physical Rig Machine Deployment (Offsets 1, 2, 3)

The physical testing rigs in Unit 3 run the compiled executable from the local disk but check the network share for updates automatically. Rig machines do **not** need Git or twinBASIC.

### Filepath Standards on Rig Machines:
* **Local Rig Folder:** `C:\offset setup files`
  * This folder contains the rig configuration files, setup databases, and the currently running executable.
* **Network Release Share:** `Q:\SENSTRONICS\CONTROLLED MACHINE SOFTWARE\Offset Rig Software VB`
  * This shared drive holds the latest compiled and tagged version of `OffsetCheck.exe`.

### Rig Installation Procedure:
1. Ensure the network `Q:` drive is mounted on the rig machine.
2. Copy the launcher files from the network share to the rig:
   * Copy `launcher.bat` and `LaunchOffsetCheck.ps1` to the rig's **Desktop** or to `C:\offset setup files\`.
3. Configure the rig configuration file `C:\offset setup files\offset_config.txt` for physical testing:
   * Set `dev_mode,0` (or delete the line).
   * Specify the physical instrument parameters (e.g., `psu_visa_id`).
4. Run the **`launcher.bat`** script on the Desktop.
   * The script will check the network share (`Q:`), download the latest compiled `OffsetCheck.exe`, and launch it.

---

## 📦 4. Release Pipeline (Deploying a New Version)

When you make changes to the source code and want to deploy a new version to the rigs:

1. **Stage and Commit Your Changes (Recommended):**
   Commit your functional code changes to Git first:
   ```bash
   git add .
   git commit -m "Your description of what changed"
   ```
   *Note: If you commit your changes first, the release script will automatically parse your commit message and add it to the release `changelog.txt`!*

2. **Run the Release Script:**
   In your terminal, run:
   ```bash
   python release.py
   ```
3. **Select Version:**
   The script will suggest the next logical patch version (e.g., `v1.0.38`). Press Enter to accept or type a custom version tag.
4. **Compile the EXE (Important IDE Step):**
   The script will inject the new version number and pause, asking you to compile.
   > [!IMPORTANT]
   > **IDE Reload Required:** If you already had twinBASIC IDE open, it is holding the old project state in memory. You **must** close and reopen the workspace/project in twinBASIC before compiling. This forces the IDE to load the updated `Project1.twinproj` file from disk.
   * Compile the project as `OffsetCheck.exe` into the repository root.
5. **Verify and Deploy:**
   * Return to the release console and press Enter.
   * The script programmatically scans `OffsetCheck.exe` to verify the new version signature was compiled correctly.
   * Once verified, the script tags the commit, pushes the code and tag to GitHub, and copies the verified `OffsetCheck.exe` and `changelog.txt` to the Q network share.

---

## 🔧 5. Redeployment Pipeline (Fixing an Existing Version)

If you ran `release.py` but compiled incorrectly (e.g., forgot to reload twinBASIC), you do **not** need to create a new version tag. You can rebuild and overwrite the current version using `redeploy.py`:

1. **Close and Reopen twinBASIC** (forces reload of the `.twinproj` file from disk).
2. **Recompile** the project to `OffsetCheck.exe`.
3. **Run the Redeployment Script:**
   ```bash
   python redeploy.py
   ```
4. Enter the expected version tag (e.g., `v1.0.37`). The script will verify the version signature inside the local binary and safely redeploy it to the network share.
