# FUXA Local Development Backup Script
# PowerShell script for backing up FUXA project configurations

param(
    [string]$BackupPath = ".\fuxa\backups",
    [string]$ProjectPath = ".\fuxa\projects",
    [string]$BackupName = "fuxa-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
)

Write-Host "=== FUXA Local Development Backup Script ===" -ForegroundColor Green
Write-Host "Backing up FUXA project configurations..." -ForegroundColor Yellow

# Create backup directory if it doesn't exist
if (!(Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force
    Write-Host "Created backup directory: $BackupPath" -ForegroundColor Green
}

# Create timestamped backup directory
$FullBackupPath = Join-Path $BackupPath $BackupName
if (!(Test-Path $FullBackupPath)) {
    New-Item -ItemType Directory -Path $FullBackupPath -Force
    Write-Host "Created backup directory: $FullBackupPath" -ForegroundColor Green
}

# Check if project directory exists
if (!(Test-Path $ProjectPath)) {
    Write-Host "Warning: Project directory does not exist: $ProjectPath" -ForegroundColor Yellow
    Write-Host "Creating empty project directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ProjectPath -Force
}

# Copy project files
try {
    if (Test-Path $ProjectPath) {
        Copy-Item -Path "$ProjectPath\*" -Destination $FullBackupPath -Recurse -Force
        Write-Host "Successfully backed up project files to: $FullBackupPath" -ForegroundColor Green
    }
} catch {
    Write-Host "Error backing up project files: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create backup manifest
$Manifest = @{
    backup_name = $BackupName
    backup_timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    source_path = (Resolve-Path $ProjectPath).Path
    backup_path = (Resolve-Path $FullBackupPath).Path
    files_backed_up = @()
}

# List backed up files
if (Test-Path $FullBackupPath) {
    $Files = Get-ChildItem -Path $FullBackupPath -Recurse -File
    $Manifest.files_backed_up = $Files | ForEach-Object { $_.FullName }
    Write-Host "Backed up $($Files.Count) files" -ForegroundColor Green
}

# Save manifest
$ManifestPath = Join-Path $FullBackupPath "backup-manifest.json"
$Manifest | ConvertTo-Json -Depth 10 | Out-File -FilePath $ManifestPath -Encoding UTF8
Write-Host "Backup manifest saved to: $ManifestPath" -ForegroundColor Green

# Create backup summary
$Summary = @"
FUXA Local Development Backup Summary
====================================
Backup Name: $BackupName
Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Source Path: $ProjectPath
Backup Path: $FullBackupPath
Files Backed Up: $($Manifest.files_backed_up.Count)

To restore this backup:
1. Stop FUXA container: docker-compose -f docker-compose.local.yml stop fuxa
2. Copy files from: $FullBackupPath
3. To: $ProjectPath
4. Restart FUXA container: docker-compose -f docker-compose.local.yml start fuxa
"@

$SummaryPath = Join-Path $FullBackupPath "backup-summary.txt"
$Summary | Out-File -FilePath $SummaryPath -Encoding UTF8
Write-Host "Backup summary saved to: $SummaryPath" -ForegroundColor Green

Write-Host "=== Backup completed successfully ===" -ForegroundColor Green
Write-Host "Backup location: $FullBackupPath" -ForegroundColor Cyan
