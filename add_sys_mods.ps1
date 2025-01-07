param (
    [Parameter(Mandatory = $true)]
    [string]$Ps1FilePath
)

# Define helper functions
function New-SafeDirectory {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        Write-Host "Creating directory: $Path"
        New-Item -ItemType Directory -Path $Path | Out-Null
    } else {
        Write-Host "Directory already exists: $Path"
    }
}

function Backup-SystemPath {
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

# Step 3: Copy the provided script and rename it as a module
Write-Host "Copying file to: $destinationFile"
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
