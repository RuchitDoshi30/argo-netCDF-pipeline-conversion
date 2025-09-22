# Installation Guide

## System Requirements

### Minimum Requirements
- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 18.04+)
- **Python**: 3.8 or higher
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space for data processing
- **Network**: Stable internet connection for data downloads

### Recommended Requirements
- **Python**: 3.9 or 3.10
- **RAM**: 16GB for large-scale processing
- **Storage**: SSD for better performance
- **CPU**: Multi-core processor for parallel processing

## Database Requirements

### PostgreSQL
- **Version**: 12 or higher (14+ recommended)
- **Extensions**: PostGIS 3.0+ (optional but recommended)
- **Configuration**: Minimum 256MB shared_buffers

## Installation Methods

### Method 1: Automated Setup (Recommended)

#### Windows
1. Open PowerShell as Administrator
2. Run the setup script:
   ```powershell
   git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
   cd argo-netCDF-pipeline-conversion
   .\scripts\setup.ps1
   ```

#### Linux/macOS
1. Open terminal
2. Run the setup script:
   ```bash
   git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
   cd argo-netCDF-pipeline-conversion
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

### Method 2: Manual Installation

#### Step 1: Python Environment
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Step 2: PostgreSQL Setup

##### Windows
1. Download PostgreSQL from https://www.postgresql.org/download/windows/
2. Run installer and remember the postgres password
3. Install PostGIS from Stack Builder or https://postgis.net/windows_downloads/

##### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib postgis
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

##### macOS
```bash
brew install postgresql postgis
brew services start postgresql
```

#### Step 3: Database Configuration
```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create database and user
CREATE DATABASE argo_data;
CREATE USER argo_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE argo_data TO argo_user;

-- Enable PostGIS (optional)
\c argo_data
CREATE EXTENSION IF NOT EXISTS postgis;
```

#### Step 4: Configuration
```bash
# Copy configuration template
cp config/config.template.json config/config.json

# Edit configuration file
# Update database credentials in config/config.json
```

## Verification

### Test Installation
```bash
# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows

# Test configuration
python -c "from src.utils.config_loader import ConfigLoader; ConfigLoader.load_config('config/config.json')"

# Test database connection
python -c "from src.database.db_manager import DatabaseManager; import json; config = json.load(open('config/config.json')); db = DatabaseManager(config['database']); print('Database connection successful')"
```

### Run Pipeline Test
```bash
# Run pipeline with help to verify installation
python src/argo_pipeline.py --help

# Run basic configuration test
python src/argo_pipeline.py --config config/config.json
```

## Troubleshooting

### Common Issues

#### Python Import Errors
```bash
# Ensure virtual environment is activated
source venv/bin/activate

# Reinstall dependencies
pip install --upgrade -r requirements.txt
```

#### Database Connection Issues
- Check PostgreSQL service status
- Verify credentials in config.json
- Ensure database exists
- Check firewall settings

#### Permission Issues (Linux/macOS)
```bash
# Make scripts executable
chmod +x scripts/setup.sh

# Fix PostgreSQL permissions if needed
sudo -u postgres createdb argo_data
```

#### PostGIS Installation Issues
- PostGIS is optional; the pipeline will work without it
- Use package manager installation when possible
- Check PostgreSQL version compatibility

### Getting Help

1. Check the [Troubleshooting Guide](../TROUBLESHOOTING.md)
2. Review [GitHub Issues](https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion/issues)
3. Create a new issue with:
   - Operating system and version
   - Python version
   - PostgreSQL version
   - Complete error messages
   - Steps to reproduce

## Next Steps

After successful installation:

1. **Configure Pipeline**: Edit `config/config.json` with your preferences
2. **Run Initial Test**: Process a small date range to verify functionality
3. **Monitor Logs**: Check `logs/argo_pipeline.log` for processing status
4. **Scale Up**: Process larger date ranges for production use

For detailed usage instructions, see the main [README.md](../README.md).