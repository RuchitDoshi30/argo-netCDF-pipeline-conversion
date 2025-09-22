# Quick Setup Script for ARGO Pipeline
# Run this script in PowerShell as Administrator

Write-Host "ARGO Data Pipeline Setup Script" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit 1
}

# Function to check if command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

Write-Host "`n1. Checking Python installation..." -ForegroundColor Yellow
if (Test-Command python) {
    $pythonVersion = python --version
    Write-Host "   ✓ Python found: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "   ✗ Python not found! Please install Python 3.8+ from https://python.org" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Checking PostgreSQL installation..." -ForegroundColor Yellow
if (Test-Command psql) {
    Write-Host "   ✓ PostgreSQL found" -ForegroundColor Green
} else {
    Write-Host "   ✗ PostgreSQL not found!" -ForegroundColor Red
    Write-Host "   Please install PostgreSQL from https://www.postgresql.org/download/windows/" -ForegroundColor Red
    Write-Host "   Make sure to remember the postgres user password!" -ForegroundColor Red
    exit 1
}

Write-Host "`n3. Setting up Python virtual environment..." -ForegroundColor Yellow
if (Test-Path "venv") {
    Write-Host "   Virtual environment already exists" -ForegroundColor Yellow
} else {
    python -m venv venv
    Write-Host "   ✓ Virtual environment created" -ForegroundColor Green
}

Write-Host "`n4. Activating virtual environment and installing dependencies..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt
Write-Host "   ✓ Dependencies installed" -ForegroundColor Green

Write-Host "`n5. Setting up PostgreSQL database..." -ForegroundColor Yellow
$dbPassword = Read-Host "Enter PostgreSQL postgres user password" -AsSecureString
$dbPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($dbPassword))

# Create database and user
$env:PGPASSWORD = $dbPasswordPlain
try {
    psql -U postgres -h localhost -c "CREATE DATABASE IF NOT EXISTS argo_data;" 2>$null
    psql -U postgres -h localhost -c "CREATE USER IF NOT EXISTS argo_user WITH PASSWORD 'argo123';" 2>$null
    psql -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE argo_data TO argo_user;" 2>$null
    
    # Try to enable PostGIS
    psql -U postgres -d argo_data -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ Database created with PostGIS extension" -ForegroundColor Green
    } else {
        Write-Host "   ✓ Database created (PostGIS not available - will use standard indexing)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Database setup failed. Please check PostgreSQL installation and password." -ForegroundColor Red
    exit 1
}

Write-Host "`n6. Creating configuration file..." -ForegroundColor Yellow
if (-not (Test-Path "config")) {
    New-Item -ItemType Directory -Path "config"
}

if (-not (Test-Path "config\config.json")) {
    Copy-Item "config\config.template.json" "config\config.json"
    
    # Update password in config file
    $configContent = Get-Content "config\config.json" -Raw
    $configContent = $configContent -replace '"password": "your_password_here"', "`"password`": `"$dbPasswordPlain`""
    $configContent | Set-Content "config\config.json"
    
    Write-Host "   ✓ Configuration file created and updated" -ForegroundColor Green
} else {
    Write-Host "   Configuration file already exists" -ForegroundColor Yellow
}

Write-Host "`n7. Creating required directories..." -ForegroundColor Yellow
$directories = @("logs", "temp", "reports")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir
    }
}
Write-Host "   ✓ Required directories created" -ForegroundColor Green

Write-Host "`n8. Testing configuration..." -ForegroundColor Yellow
python -c "
import sys, os
sys.path.insert(0, 'src')
from utils.config_loader import ConfigLoader
try:
    config = ConfigLoader.load_config('config/config.json')
    print('   ✓ Configuration validation successful')
except Exception as e:
    print(f'   ✗ Configuration validation failed: {e}')
    sys.exit(1)
"

# Clear the password from environment
$env:PGPASSWORD = $null
Remove-Variable dbPasswordPlain

Write-Host "`n🎉 Setup Complete!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Activate the virtual environment: .\venv\Scripts\Activate.ps1" -ForegroundColor White  
Write-Host "2. Run the pipeline: python src\argo_pipeline.py" -ForegroundColor White
Write-Host "3. View logs in the logs/ directory" -ForegroundColor White
Write-Host "`nFor more information, see README.md" -ForegroundColor White