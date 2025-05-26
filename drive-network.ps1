param (
    [Parameter(Mandatory = $true)]
    [string]$NetworkShare, # Example: \\server\projects

    [Parameter(Mandatory = $true)]
    [string]$LocalTarget, # Example: C:\projects

    [Parameter()]
    [string]$DriveLetter = "R"
)

# ============================================
# 1. Ask for credentials
# ============================================
$credential = Get-Credential -Message "Introduce credentials to acces to $NetworkShare"

# ============================================
# 2. Connect to network share
# ============================================
Write-Host "`n🔌 Connecting unit '$DriveLetter': to $NetworkShare..." -ForegroundColor Cyan

Try {
    New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $NetworkShare -Credential $credential -Persist -ErrorAction Stop
}
Catch {
    Write-Error "❌ Error Connecting to Drive networkshare: $_"; exit 1
}

# ============================================
# 2. Sync folders
# ============================================

$sourceRoot = "$($DriveLetter):\"
$targetRoot = $LocalTarget
try {
    pwsh .\sync.ps1 -SourceRoot $sourceRoot -TargetRoot $targetRoot
}
catch {
    Write-Host "❌ Error synchronizing folders." -ForegroundColor Red
}


# ============================================
# 4. Disconnect drive netkworkshare
# ============================================

Write-Host "`n🔌 Disconnecting unit '$DriveLetter':..." -ForegroundColor Cyan
Remove-PSDrive -Name $DriveLetter -Force

Write-Host "✅ Share unit disconnected." -ForegroundColor Green