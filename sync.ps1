param (
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot,

    [Parameter(Mandatory = $true)]
    [string]$TargetRoot
)

# ============================================
# SETTING
# ============================================

# rsync path
$rsyncPath = "C:\ProgramData\chocolatey\lib\rsync\tools\bin\rsync.exe"

# ============================================
# CHECK RSYNC PATH
# ============================================

if (-not (Test-Path $rsyncPath)) {
    Write-Error "❌ rsync no found in: $rsyncPath"
    exit 1
}

# Check Source and Target paths
if (-not (Test-Path $SourceRoot)) {
    Write-Error "❌ Source folder doesn't exist: $SourceRoot"
    exit 1
}
if (-not (Test-Path $TargetRoot)) {
    New-Item -ItemType Directory -Path $TargetRoot | Out-Null
    Write-Host "📁 Target folder has been created: $TargetRoot"
}


function Convert-ToRsyncPath {
    param([string]$windowsPath)
    # Convert C:\path\to\folder ➜ /cygdrive/c/path/to/folder
    $drive = $windowsPath.Substring(0,1).ToLower()
    $rest = $windowsPath.Substring(2) -replace '\\','/'
    return "/cygdrive/$drive/$rest"
}

# ============================================
# LOOP OVER PROJECTS
# ============================================

Get-ChildItem -Path $SourceRoot -Directory | ForEach-Object {
    $projectName = $_.Name
    $sourcePath = Join-Path $SourceRoot $projectName
    $targetPath = Join-Path $TargetRoot $projectName

    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Path $targetPath | Out-Null
    }

    $sourceRsync = Convert-ToRsyncPath "$sourcePath\"
    $targetRsync = Convert-ToRsyncPath "$targetPath\"

    Write-Host "`n🔄 Synchronizing '$projectName'..."
    Write-Host "   Sorce: $sourceRsync"
    Write-Host "   Target: $targetRsync"

    & $rsyncPath -av --delete $sourceRsync $targetRsync

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project '$projectName' synchronized." -ForegroundColor Green
    } else {
        Write-Host "❌ Error synchronizing '$projectName'." -ForegroundColor Red
    }
}