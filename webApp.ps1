function StopIISWebApp([string]$WebHost, [string]$Website, [string]$App, [string]$AppPool = $null) { 
    if (-not $WebHost) {
        Write-Error "WebHost is Required"; exit 1
    }
    if (-not $Website) {
        Write-Error "Website is Required"; exit 1
    }
    if (-not $App) {
        Write-Error "App is Required"; exit 1
    }
    if (-not $AppPool) {
        $AppPool = $Website
    }
    Invoke-Command -Computername $WebHost -Scriptblock { 
        Import-Module WebAdministration
        Write-Host "Stopping $using:Website@$using:App..."
        Remove-WebApplication -Site "$using:Website" -Name "$using:App" -ErrorAction SilentlyContinue

        $appPoolName = $using:AppPool
        if ($appPoolName) {
            $appPoolState = (Get-WebAppPoolState -Name $appPoolName).Value
            $timeout = [System.TimeSpan]::FromMinutes(3)
            $stopWatch = New-Object -TypeName 'System.Diagnostics.Stopwatch'
            $stopWatch.Start()
            # Possible status: "Starting", "Started", "Stopping", "Stopped" and "Unknown".
            while ($appPoolState -ne 'Stopped') {
                if ($appPoolState -eq 'Started') {
                    Write-Host "Stopping AppPool: $appPoolName"
                    Stop-WebAppPool -Name "$appPoolName" -ErrorAction SilentlyContinue
                }
                Start-Sleep -Seconds 5
                if ($stopWatch.Elapsed -gt $timeout) {
                    Write-Error "Timeout of $($timeout.TotalSeconds) seconds exceeded"; exit 1
                }
                $appPoolState = (Get-WebAppPoolState -Name $AppPoolName).Value
            }
        }
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
}

function DeployWebApp([string]$WebHost, [string]$Website, [string]$App, [string]$TargetPath, [string]$SourcePath, [string]$AppPool = $null) {
    LogStartTask -Task "-- DeployWebApp"

    Write-Host "WebHost: $WebHost"
    Write-Host "Website: $Website"
    Write-Host "App: $App"
    Write-Host "Source folder: $SourcePath"
    Write-Host "Target folder: $TargetPath"

    StopIISWebApp -WebHost $WebHost -Website $Website -App $App -AppPool $AppPool

    CleanFolder -Path $TargetPath

    Write-Host "Copying files to target folder"
    Copy-Item -Path "$SourcePath/*" -Destination "$TargetPath" -Recurse -Force

    StartIISWebSite -WebHost $WebHost -Website $Website -AppPool $AppPool
}
