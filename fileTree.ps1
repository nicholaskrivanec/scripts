function Show-File-Tree {
    param (
        [string]$PathName,
        [string[]]$Exclude
    )

    # Check if the provided path exists
    if (-Not (Test-Path -Path $PathName)) {
        Write-Error "The specified path does not exist: $PathName"
        return
    }

    # Recursive helper function to build the tree
    function Get-Tree {
        param (
            [string]$CurrentPath,
            [string[]]$ExcludeList,
            [int]$IndentLevel
        )

        # Get all child items in the current path
        $items = Get-ChildItem -Path $CurrentPath -Force | Sort-Object -Property Name

        foreach ($item in $items) {
            # Skip excluded directories
            if ($item.PSIsContainer -and ($ExcludeList -contains $item.Name)) {
                continue
            }

            # Display the item with indentation
            $prefix = (' ' * $IndentLevel) + "├───"
            Write-Host "$prefix $($item.Name)"

            # Recursively process subdirectories
            if ($item.PSIsContainer) {
                Get-Tree -CurrentPath $item.FullName -ExcludeList $ExcludeList -IndentLevel ($IndentLevel + 4)
            }
        }
    }

    # Display the root folder
    Write-Host $PathName
    # Start building the tree
    Get-Tree -CurrentPath $PathName -ExcludeList $Exclude -IndentLevel 0
}

$fp = "X:\00_Development\w3project"
$dontShow = @("node_modules", "dist", "sandbox", ".git")

Show-File-Tree -PathName $fp -Exclude $dontShow
