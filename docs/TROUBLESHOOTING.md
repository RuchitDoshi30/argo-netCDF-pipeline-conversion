# Troubleshooting Guide

## Quick Diagnostic Commands

### System Check
```bash
# Check Python version
python --version

# Check PostgreSQL
psql --version

# Test database connection
psql -U postgres -h localhost -c "\l"

# Verify virtual environment
which python  # Should point to venv/bin/python

# Check installed packages
pip list | grep -E "(requests|psycopg2|xarray|numpy)"
```

### Configuration Validation
```bash
# Test configuration loading
python -c "from src.utils.config_loader import ConfigLoader; ConfigLoader.load_config('config/config.json')"

# Test database connection
python -c "from src.database.db_manager import DatabaseManager; import json; config = json.load(open('config/config.json')); db = DatabaseManager(config['database']); print('Success')"
```

### Pipeline Test
```bash
# Test pipeline help
python src/argo_pipeline.py --help

# Test configuration parsing
python src/argo_pipeline.py --config config/config.json --version
```

## Common Installation Issues

### 1. Python Environment Issues

#### Problem: "Command 'python' not found"
**Solution:**
```bash
# Use python3 explicitly
python3 --version
python3 -m venv venv

# Or add Python to PATH (Windows)
# Add Python installation directory to system PATH
```

#### Problem: "No module named 'venv'"
**Solution:**
```bash
# Install python3-venv (Ubuntu/Debian)
sudo apt install python3-venv

# Or use virtualenv
pip install virtualenv
virtualenv venv
```

#### Problem: Virtual environment not activating
**Solution:**
```bash
# Windows PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\venv\Scripts\Activate.ps1

# Windows Command Prompt
venv\Scripts\activate.bat

# Linux/macOS
source venv/bin/activate
```

### 2. PostgreSQL Installation Issues

#### Problem: "postgresql service not found"
**Windows:**
```powershell
# Check service status
Get-Service -Name "*postgres*"

# Start service
Start-Service postgresql-x64-15

# Or use net command
net start postgresql-x64-15
```

**Linux:**
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start and enable service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Check status
sudo systemctl status postgresql
```

**macOS:**
```bash
# Install with Homebrew
brew install postgresql

# Start service
brew services start postgresql

# Check status
brew services list | grep postgresql
```

#### Problem: "FATAL: password authentication failed"
**Solution:**
```bash
# Reset postgres password (Linux/macOS)
sudo -u postgres psql
ALTER USER postgres PASSWORD 'new_password';
\q

# Windows (as Administrator)
psql -U postgres
ALTER USER postgres PASSWORD 'new_password';
\q

# Update pg_hba.conf if needed
# Change authentication method to 'md5' or 'trust'
```

#### Problem: "could not connect to server"
**Solutions:**
1. **Check if PostgreSQL is running:**
   ```bash
   # Linux
   sudo systemctl status postgresql
   
   # macOS
   brew services list | grep postgresql
   
   # Windows
   Get-Service postgresql*
   ```

2. **Check PostgreSQL configuration:**
   ```bash
   # Edit postgresql.conf
   listen_addresses = 'localhost'
   port = 5432
   ```

3. **Check firewall settings:**
   ```bash
   # Linux - allow PostgreSQL port
   sudo ufw allow 5432
   
   # Windows - check Windows Firewall
   ```

### 3. PostGIS Installation Issues

#### Problem: "could not open extension control file"
**Solutions:**

**Ubuntu/Debian:**
```bash
sudo apt install postgis postgresql-15-postgis-3
```

**CentOS/RHEL:**
```bash
sudo yum install postgis postgresql15-postgis
```

**Windows:**
- Use Stack Builder during PostgreSQL installation
- Or download from https://postgis.net/windows_downloads/

**macOS:**
```bash
brew install postgis
```

#### Problem: PostGIS functions not available
**Solution:**
```sql
-- Connect to database
psql -U postgres -d argo_data

-- Install PostGIS extension
CREATE EXTENSION postgis;

-- Verify installation
SELECT PostGIS_Version();
```

### 4. Python Package Installation Issues

#### Problem: "No module named 'psycopg2'"
**Solutions:**
```bash
# Try binary version first
pip install psycopg2-binary

# If compilation needed, install dependencies
# Ubuntu/Debian
sudo apt install python3-dev libpq-dev
pip install psycopg2

# CentOS/RHEL
sudo yum install python3-devel postgresql-devel
pip install psycopg2

# macOS
brew install postgresql
pip install psycopg2
```

#### Problem: "No module named '_netCDF4'"
**Solutions:**
```bash
# Using conda (recommended)
conda install netcdf4

# Using pip with system libraries
# Ubuntu/Debian
sudo apt install libnetcdf-dev libhdf5-dev
pip install netcdf4

# macOS
brew install netcdf hdf5
pip install netcdf4

# Windows - use conda or pre-compiled wheels
conda install netcdf4
```

#### Problem: "Microsoft Visual C++ 14.0 is required" (Windows)
**Solutions:**
1. **Install Microsoft C++ Build Tools**
2. **Use conda instead of pip for scientific packages:**
   ```bash
   conda install numpy pandas xarray netcdf4
   ```
3. **Use pre-compiled wheels:**
   ```bash
   pip install --only-binary=all netcdf4
   ```

## Runtime Issues

### 1. Database Connection Issues

#### Problem: "connection timeout"
**Solutions:**
```json
// Increase timeout in config.json
"database": {
  "connection_timeout": 60,
  "connection_pool_size": 5
}
```

#### Problem: "too many connections"
**Solutions:**
1. **Reduce connection pool size:**
   ```json
   "connection_pool_size": 5
   ```

2. **Increase PostgreSQL max_connections:**
   ```sql
   -- Edit postgresql.conf
   max_connections = 200
   ```

3. **Check for connection leaks in code**

### 2. Network and Data Access Issues

#### Problem: "Connection timeout to data-argo.ifremer.fr"
**Solutions:**
1. **Check internet connection**
2. **Increase timeout:**
   ```json
   "data_source": {
     "timeout_seconds": 60,
     "retry_attempts": 5
   }
   ```

3. **Use proxy if behind firewall:**
   ```bash
   export https_proxy=http://proxy.company.com:8080
   ```

4. **Try alternative data sources**

#### Problem: "SSL Certificate verification failed"
**Temporary workaround (not recommended for production):**
```python
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
```

**Better solution:**
```bash
# Update certificates
# Ubuntu/Debian
sudo apt update && sudo apt install ca-certificates

# macOS
brew install ca-certificates

# Windows - update Windows or use conda
conda update ca-certificates
```

### 3. Memory and Performance Issues

#### Problem: "MemoryError: Unable to allocate array"
**Solutions:**
1. **Reduce parallel processing:**
   ```json
   "processing": {
     "max_workers": 1,
     "chunk_size": 100
   }
   ```

2. **Increase virtual memory (swap):**
   ```bash
   # Linux - create swap file
   sudo fallocate -l 4G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

3. **Process smaller date ranges**

4. **Use data streaming instead of loading all in memory**

#### Problem: "Database connection limit exceeded"
**Solutions:**
1. **Reduce connection pool:**
   ```json
   "connection_pool_size": 3
   ```

2. **Add connection pooling:**
   ```python
   # Use connection context managers
   with db_manager.get_connection() as conn:
       # Use connection
       pass
   # Connection automatically returned to pool
   ```

### 4. Data Quality Issues

#### Problem: "No valid data found for processing"
**Debugging steps:**
1. **Check date range validity**
2. **Verify network access to ARGO repository**
3. **Inspect raw NetCDF files:**
   ```python
   import xarray as xr
   ds = xr.open_dataset('profile_file.nc')
   print(ds.variables)
   print(ds.dims)
   ```

4. **Check QC thresholds:**
   ```json
   "quality_control": {
     "thresholds": {
       "min_good_data_percentage": 30.0
     }
   }
   ```

#### Problem: "All profiles marked as unusable quality"
**Solutions:**
1. **Review QC thresholds - may be too strict**
2. **Check for corrupted data files**
3. **Verify parameter units and ranges**
4. **Enable debug logging to see QC decisions:**
   ```json
   "logging": {"level": "DEBUG"}
   ```

## Platform-Specific Issues

### Windows Issues

#### Problem: "PowerShell execution policy restricts script running"
**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Problem: "'psql' is not recognized as an internal command"
**Solution:**
Add PostgreSQL bin directory to PATH:
1. Open System Properties → Advanced → Environment Variables
2. Add to PATH: `C:\Program Files\PostgreSQL\15\bin`
3. Restart command prompt

### Linux/macOS Issues

#### Problem: "Permission denied" when running scripts
**Solution:**
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### Problem: "sudo: no tty present and no askpass program specified"
**Solution:**
Run commands manually without sudo, or configure passwordless sudo:
```bash
# Add to /etc/sudoers (use visudo)
username ALL=(postgres) NOPASSWD: ALL
```

## Getting Detailed Diagnostics

### Enable Debug Logging
```json
// In config.json
"logging": {
  "level": "DEBUG",
  "file": "logs/debug.log"
}
```

### System Information Script
```bash
python -c "
import sys, platform, psycopg2, xarray, numpy
print(f'Python: {sys.version}')
print(f'Platform: {platform.platform()}')
print(f'NumPy: {numpy.__version__}')
print(f'XArray: {xarray.__version__}')
print(f'psycopg2: {psycopg2.__version__}')
"
```

### Resource Monitoring
```bash
# Linux/macOS - monitor resource usage
top -p $(pgrep -f argo_pipeline)

# Windows
Get-Process python | Select-Object ProcessName,CPU,WorkingSet
```

### Database Diagnostics
```sql
-- Check database size
SELECT pg_size_pretty(pg_database_size('argo_data'));

-- Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::text)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(tablename::text) DESC;

-- Check active connections
SELECT count(*) FROM pg_stat_activity;
```

## Getting Help

### Information to Include in Bug Reports

1. **System Information:**
   - Operating system and version
   - Python version
   - PostgreSQL version
   - PostGIS version (if applicable)

2. **Configuration:**
   - Relevant parts of config.json (remove passwords)
   - Command line arguments used

3. **Error Details:**
   - Complete error message and stack trace
   - Log files (with DEBUG level if possible)
   - Steps to reproduce

4. **Environment:**
   - Virtual environment details
   - Installed package versions
   - Network configuration (if relevant)

### Where to Get Help

1. **GitHub Issues**: https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion/issues
2. **Documentation**: Check all files in `docs/` directory
3. **Community**: GitHub Discussions for questions and tips

### Before Asking for Help

1. **Search existing issues** for similar problems
2. **Try the solutions** in this troubleshooting guide
3. **Test with minimal configuration** to isolate the issue
4. **Provide detailed information** when creating issues

---

**Remember**: Most issues are configuration or environment-related. Double-check your setup before assuming there's a bug in the code.