function Update-WorkspaceRepositories {
    param (
        [string]$WorkspacePath = "X:\00_Development\projects",  # Default workspace path
        [string]$WorkspaceFile = "X:\00_Development\projects\projects.code-workspace",  # Default workspace file
        [string]$GitHubUser = "nicholaskrivanec",  # GitHub username
        [int]$RepoLimit = 100  # Limit on repositories to fetch
    )

    # Step 1: Get a list of local repositories
    Write-Host "Fetching local repositories in $WorkspacePath..."
    $localRepos = Get-ChildItem -Directory -Path $WorkspacePath | Select-Object -ExpandProperty Name

    # Step 2: Get a list of remote repositories from GitHub
    Write-Host "Fetching remote repositories for user $GitHubUser..."
    try {
        $remoteRepos = gh repo list $GitHubUser --limit $RepoLimit --json nameWithOwner | ConvertFrom-Json
    } catch {
        Write-Error "Failed to fetch repositories from GitHub. Ensure GitHub CLI is authenticated."
        return
    }

    # Step 3: Clone missing repositories
    Write-Host "Checking for missing repositories..."
    $clonedRepos = @()
    $remoteRepos | ForEach-Object {
        $repoName = $_.nameWithOwner.Split('/')[1]
        if ($localRepos -notcontains $repoName) {
            Write-Host "Cloning repository: $($_.nameWithOwner)"
            gh repo clone $_.nameWithOwner $WorkspacePath
            $clonedRepos += $repoName
        } else {
            Write-Host "Skipping already cloned repository: $($_.nameWithOwner)"
        }
    }

    # Step 4: Update the workspace file
    Write-Host "Updating the workspace file at $WorkspaceFile..."
    if (Test-Path $WorkspaceFile) {
        $workspaceJson = Get-Content $WorkspaceFile -Raw | ConvertFrom-Json
    } else {
        $workspaceJson = [PSCustomObject]@{
            folders = @()
            settings = @{}
        }
    }

    # Add new repositories to the workspace file
    $existingFolders = $workspaceJson.folders | ForEach-Object { $_.path }
    $newFolders = Get-ChildItem -Directory -Path $WorkspacePath | ForEach-Object {
        $relativePath = ".\" + $_.Name
        if ($existingFolders -notcontains $relativePath) {
            [PSCustomObject]@{ path = $relativePath }
        }
    }

    # Update and save the workspace JSON structure
    $workspaceJson.folders = $workspaceJson.folders + $newFolders
    $workspaceJson | ConvertTo-Json -Depth 10 | Set-Content $WorkspaceFile

    Write-Host "Workspace file updated successfully at $WorkspaceFile"
}