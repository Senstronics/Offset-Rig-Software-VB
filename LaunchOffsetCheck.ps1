# LaunchOffsetCheck.ps1
# This script manages the automatic updating and launching of the Offset Rig Software.

$NetworkPath = "Q:\SENSTRONICS\CONTROLLED MACHINE SOFTWARE\Offset Rig Software VB"
$NetworkExe = Join-Path $NetworkPath "OffsetCheck.exe"

$LocalDir = "C:\offset setup files"
$LocalExe = Join-Path $LocalDir "OffsetCheck.exe"

Write-Host "Checking for software updates at: $NetworkPath"

# Create local directory if it doesn't exist
if (-not (Test-Path $LocalDir)) {
    try {
        New-Item -ItemType Directory -Path $LocalDir -Force | Out-Null
    } catch {
        Write-Warning "Could not create directory $LocalDir. Falling back to script directory."
        $LocalDir = $PSScriptRoot
        $LocalExe = Join-Path $LocalDir "OffsetCheck.exe"
    }
}

$UpdateRequired = $false

if (Test-Path $NetworkExe) {
    if (Test-Path $LocalExe) {
        $NetworkDate = (Get-Item $NetworkExe).LastWriteTime
        $LocalDate = (Get-Item $LocalExe).LastWriteTime
        
        if ($NetworkDate -gt $LocalDate) {
            $UpdateRequired = $true
            Write-Host "Network version is newer: $NetworkDate vs Local: $LocalDate"
        } else {
            Write-Host "Local version is up to date."
        }
    } else {
        $UpdateRequired = $true
        Write-Host "Local executable not found. Copying from network..."
    }

    if ($UpdateRequired) {
        Write-Host "Updating OffsetCheck.exe from network..."
        $Copied = $false
        
        # Attempt to copy up to 5 times (in case the running application is still closing)
        for ($i = 1; $i -le 5; $i++) {
            try {
                Copy-Item -Path $NetworkExe -Destination $LocalExe -Force -ErrorAction Stop
                $Copied = $true
                Write-Host "Update completed successfully."
                break
            } catch {
                Write-Host "Executable file is locked. Retrying copy in 1 second... ($i/5)"
                Start-Sleep -Seconds 1
            }
        }
        
        if (-not $Copied) {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show(
                "Could not copy the new executable from the network.`n`nPlease ensure the Offset Rig Software is fully closed and try again.", 
                "Update Error", 
                [System.Windows.Forms.MessageBoxButtons]::OK, 
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    }
} else {
    Write-Warning "Network release path is unreachable. Running local version."
}

if (Test-Path $LocalExe) {
    Write-Host "Launching Offset Rig Software..."
    Start-Process -FilePath $LocalExe
} else {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
        "Could not locate OffsetCheck.exe locally or on the network.`n`nPlease contact engineering.", 
        "Execution Error", 
        [System.Windows.Forms.MessageBoxButtons]::OK, 
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}
