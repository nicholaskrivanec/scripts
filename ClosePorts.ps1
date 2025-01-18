function ClosePorts{
    param (
        [string[]]$ports = @("3000", "3001")
    )

    Write-Output "Protocol  Local Address           Foreign Address       State        PID"

    $uniquePIDs = [System.Collections.Generic.HashSet[int]]::new()

    $ports | ForEach-Object { 
        netstat -ano | 
        Select-String -Pattern "($_)" | 
        Where-Object { $_ -match "LISTENING|ESTABLISHED" } | 
        ForEach-Object { 
            $columns = $_.ToString() -split "\s+"

            if ($columns.Length -ge 5 -and $columns[-1] -match '^\d+$') {
                $protocol = $columns[0]
                $localAddress = $columns[1]
                $foreignAddress = $columns[2]
                $state = $columns[3]
                $processId = [int]$columns[-1] 
                
                if ($uniquePIDs.Add($processId)) { 
                    Write-Output ("{0,-9} {1,-22} {2,-22} {3,-12} {4}" -f $protocol, $localAddress, $foreignAddress, $state, $processId)
                    
                    try {
                        Stop-Process -Id $processId -Force -ErrorAction Stop
                        Write-Output "Process with PID $($processId) has been terminated."
                    }
                    catch {  Write-Output ("Failed to terminate process with PID $($processId): $($Error[0].ToString())")}
                } else {  Write-Output "Skipping duplicate PID $($processId)" }
            } else { Write-Output "Unexpected format in netstat output: $_" }
        }
    }
}