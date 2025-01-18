<#
.SYNOPSIS
Sets up a PowerShell module by copying a provided .ps1 script, converting it to a .psm1 module, and configuring the environment.

.DESCRIPTION
This script automates the process of setting up a PowerShell module. It ensures the destination directory exists,
backs up the system PATH variable, updates or overwrites the specified .psm1 file, adds the module's location to the system PATH,
and imports the module for immediate use.

.PARAMETER Ps1FilePath
The file path to the .ps1 script that will be converted into a .psm1 module. This parameter is mandatory.

.EXAMPLE
.\add_sys_mods.ps1 -Ps1FilePath "C:\Path\To\YourScript.ps1"

Copies the provided script, converts it to a .psm1 file in "C:\Scripts", and updates the system PATH.

.EXAMPLE
.\add_sys_mods.ps1 -Ps1FilePath ".\Scripts\MyScript.ps1"

Uses a relative path to copy and convert the script to a module.

.NOTES
- The destination directory is fixed at "C:\Scripts".
- The system PATH is updated only if "C:\Scripts" is not already included.
- Requires PowerShell 5.1 or later.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Ps1FilePath
)

# Define helper functions
function New-SafeDirectory {
    <#
    .SYNOPSIS
    Ensures a directory exists. Creates the directory if it does not already exist.

    .PARAMETER Path
    The directory path to check or create.
    #>
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        Write-Host "Creating directory: $Path"
        New-Item -ItemType Directory -Path $Path | Out-Null
    } else {
        Write-Host "Directory already exists: $Path"
    }
}

function Backup-SystemPath {
    <#
    .SYNOPSIS
    Backs up the current system PATH variable to a file.

    .PARAMETER BackupFile
    The file path where the system PATH variable will be saved.
    #>
    param([string]$BackupFile)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    try {
        Set-Content -Path $BackupFile -Value $currentPath
        Write-Host "System PATH backed up to: $BackupFile"
    } catch {
        Write-Error "Failed to back up the system PATH: $_"
        Read-Host "Press Enter to exit."
        exit 1
    }
}

function Add-ToSystemPath {
    <#
    .SYNOPSIS
    Adds a directory to the system PATH variable if it's not already included.

    .PARAMETER Path
    The directory path to add to the system PATH.
    #>
    param([string]$Path)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$Path*") {
        Write-Host "Adding $Path to the system PATH."
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$Path", [EnvironmentVariableTarget]::Machine)
    } else {
        Write-Host "$Path is already in the system PATH."
    }
}

Write-Host "Script started"

# Resolve the provided script path
try {
    $absolutePath = Resolve-Path -Path $Ps1FilePath -ErrorAction Stop
} catch {
    Write-Error "The specified file does not exist: $Ps1FilePath"
    exit 1
}

# Define backup and destination paths
$backupFile = "C:\Scripts\path_backup.txt"
$destinationDir = "C:\Scripts"
$destinationFile = Join-Path -Path $destinationDir -ChildPath "$([System.IO.Path]::GetFileNameWithoutExtension($Ps1FilePath)).psm1"

# Step 1: Ensure the destination directory exists
New-SafeDirectory -Path $destinationDir

# Step 2: Back up the system PATH
Backup-SystemPath -BackupFile $backupFile

# Step 3: Update or overwrite the module file
if (Test-Path -Path $destinationFile) {
    Write-Host "Module file already exists: $destinationFile. Overwriting..."
} else {
    Write-Host "Module file does not exist. Creating new file..."
}
Copy-Item -Path $absolutePath -Destination $destinationFile -Force

# Step 4: Add the destination directory to the system PATH
Add-ToSystemPath -Path $destinationDir

# Step 5: Import all .psm1 modules in the destination directory
Get-ChildItem -Path $destinationDir -Filter "*.psm1" | ForEach-Object {
    $modulePath = $_.FullName
    if (-not (Get-Module -ListAvailable | Where-Object { $_.Path -eq $modulePath })) {
        Write-Host "Importing module: $modulePath"
        Import-Module -Name $modulePath
    } else {
        Write-Host "Module already imported: $modulePath"
    }
}

Write-Host "Script setup completed successfully. PATH backup saved at $backupFile."
