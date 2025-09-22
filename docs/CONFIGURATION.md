# Configuration Guide

## Overview

The ARGO pipeline uses JSON configuration files to manage all settings. The main configuration file is `config/config.json`, which is created from the template during setup.

## Configuration Structure

### Complete Configuration Example

```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "database": "argo_data",
    "user": "postgres",
    "password": "your_password",
    "connection_pool_size": 10,
    "enable_postgis": true,
    "connection_timeout": 30
  },
  "data_source": {
    "base_url": "https://data-argo.ifremer.fr/geo/indian_ocean",
    "timeout_seconds": 30,
    "retry_attempts": 3,
    "retry_delay": 2
  },
  "processing": {
    "max_workers": 2,
    "chunk_size": 1000,
    "temp_directory": "./temp",
    "enable_parallel_processing": true
  },
  "quality_control": {
    "thresholds": {
      "TEMP": {
        "min": -2.5,
        "max": 40.0,
        "spike_threshold": 5.0,
        "gradient_threshold": 2.0
      },
      "PSAL": {
        "min": 2.0,
        "max": 42.0,
        "spike_threshold": 2.0,
        "gradient_threshold": 1.0
      },
      "PRES": {
        "min": 0.0,
        "max": 11000.0,
        "spike_threshold": 100.0,
        "gradient_threshold": 50.0
      },
      "density_inversion_threshold": 0.05,
      "min_good_data_percentage": 70.0,
      "max_depth_gap": 500.0,
      "min_profile_length": 5
    }
  },
  "logging": {
    "level": "INFO",
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "file": "logs/argo_pipeline.log",
    "max_file_size": "10MB",
    "backup_count": 5
  },
  "output": {
    "generate_reports": true,
    "report_directory": "./reports",
    "export_formats": ["json", "csv"]
  }
}
```

## Configuration Sections

### Database Configuration

```json
"database": {
  "host": "localhost",              // Database server hostname
  "port": 5432,                     // PostgreSQL port (default: 5432)
  "database": "argo_data",          // Database name
  "user": "postgres",              // Database username
  "password": "your_password",      // Database password
  "connection_pool_size": 10,       // Maximum concurrent connections
  "enable_postgis": true,           // Enable PostGIS spatial features
  "connection_timeout": 30          // Connection timeout in seconds
}
```

**Database Settings:**
- `host`: Database server hostname or IP address
- `port`: PostgreSQL port number
- `database`: Name of the database for ARGO data
- `user`: Database username with appropriate privileges
- `password`: Database password (keep secure!)
- `connection_pool_size`: Number of concurrent database connections
- `enable_postgis`: Whether to use PostGIS spatial features
- `connection_timeout`: Maximum time to wait for database connection

### Data Source Configuration

```json
"data_source": {
  "base_url": "https://data-argo.ifremer.fr/geo/indian_ocean",
  "timeout_seconds": 30,            // HTTP request timeout
  "retry_attempts": 3,              // Number of retry attempts
  "retry_delay": 2                  // Delay between retries (seconds)
}
```

**Data Source Settings:**
- `base_url`: Base URL for ARGO data repository
- `timeout_seconds`: HTTP request timeout
- `retry_attempts`: Number of retry attempts for failed downloads
- `retry_delay`: Delay between retry attempts

### Processing Configuration

```json
"processing": {
  "max_workers": 2,                 // Number of parallel workers
  "chunk_size": 1000,               // Batch size for processing
  "temp_directory": "./temp",       // Temporary file directory
  "enable_parallel_processing": true // Enable parallel processing
}
```

**Processing Settings:**
- `max_workers`: Number of parallel processing threads
- `chunk_size`: Number of files to process in each batch
- `temp_directory`: Directory for temporary files
- `enable_parallel_processing`: Whether to use parallel processing

### Quality Control Configuration

```json
"quality_control": {
  "thresholds": {
    "TEMP": {
      "min": -2.5,                   // Minimum valid temperature (°C)
      "max": 40.0,                   // Maximum valid temperature (°C)
      "spike_threshold": 5.0,        // Temperature spike detection threshold
      "gradient_threshold": 2.0      // Temperature gradient threshold
    },
    "PSAL": {
      "min": 2.0,                    // Minimum valid salinity (PSU)
      "max": 42.0,                   // Maximum valid salinity (PSU)
      "spike_threshold": 2.0,        // Salinity spike detection threshold
      "gradient_threshold": 1.0      // Salinity gradient threshold
    },
    "PRES": {
      "min": 0.0,                    // Minimum valid pressure (dbar)
      "max": 11000.0,                // Maximum valid pressure (dbar)
      "spike_threshold": 100.0,      // Pressure spike detection threshold
      "gradient_threshold": 50.0     // Pressure gradient threshold
    },
    "density_inversion_threshold": 0.05,  // Density inversion threshold (kg/m³)
    "min_good_data_percentage": 70.0,     // Minimum percentage of good data
    "max_depth_gap": 500.0,               // Maximum gap between measurements (m)
    "min_profile_length": 5               // Minimum number of measurements
  }
}
```

**Quality Control Settings:**
- Physical limits for temperature, salinity, and pressure
- Spike detection thresholds for identifying anomalous values
- Gradient thresholds for detecting unrealistic changes
- Data quality requirements for profile acceptance

### Logging Configuration

```json
"logging": {
  "level": "INFO",                  // Log level (DEBUG, INFO, WARNING, ERROR)
  "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
  "file": "logs/argo_pipeline.log", // Log file path
  "max_file_size": "10MB",         // Maximum log file size
  "backup_count": 5                // Number of backup log files
}
```

**Logging Settings:**
- `level`: Minimum log level to record
- `format`: Log message format string
- `file`: Path to log file
- `max_file_size`: Maximum size before log rotation
- `backup_count`: Number of backup log files to keep

### Output Configuration

```json
"output": {
  "generate_reports": true,         // Generate quality reports
  "report_directory": "./reports", // Directory for reports
  "export_formats": ["json", "csv"] // Export file formats
}
```

## Environment-Specific Configurations

### Development Configuration

For development, you might want:
- More verbose logging (`DEBUG` level)
- Smaller batch sizes for testing
- Relaxed quality control thresholds

```json
{
  "logging": { "level": "DEBUG" },
  "processing": { "chunk_size": 10 },
  "quality_control": {
    "thresholds": {
      "min_good_data_percentage": 50.0
    }
  }
}
```

### Production Configuration

For production, optimize for:
- Performance (`INFO` or `WARNING` log level)
- Larger batch sizes
- Strict quality control

```json
{
  "logging": { "level": "WARNING" },
  "processing": { 
    "chunk_size": 5000,
    "max_workers": 8
  },
  "quality_control": {
    "thresholds": {
      "min_good_data_percentage": 80.0
    }
  }
}
```

## Configuration Management

### Multiple Configurations

You can maintain multiple configuration files:

```bash
# Different configurations for different environments
config/
├── config.template.json    # Template
├── config.json            # Default configuration
├── config.dev.json        # Development settings
├── config.prod.json       # Production settings
└── config.test.json       # Testing settings
```

Use specific configurations:

```bash
# Use development configuration
python src/argo_pipeline.py --config config/config.dev.json

# Use production configuration
python src/argo_pipeline.py --config config/config.prod.json
```

### Environment Variables

Sensitive settings can be overridden with environment variables:

```bash
# Set database password via environment variable
export ARGO_DB_PASSWORD="secure_password"

# Database host for containerized deployments
export ARGO_DB_HOST="postgres.example.com"
```

### Security Considerations

1. **Never commit passwords** to version control
2. **Use environment variables** for sensitive data
3. **Restrict file permissions** on configuration files:
   ```bash
   chmod 600 config/config.json
   ```
4. **Use strong passwords** for database access
5. **Enable SSL/TLS** for database connections in production

## Validation

The pipeline validates configuration on startup:

```python
# Test configuration validity
python -c "from src.utils.config_loader import ConfigLoader; ConfigLoader.load_config('config/config.json')"
```

Common validation errors:
- Missing required sections
- Invalid data types
- File path issues
- Database connection problems

## Performance Tuning

### Database Performance

```json
"database": {
  "connection_pool_size": 20,  // Increase for high concurrency
  "connection_timeout": 60     // Increase for slow networks
}
```

### Processing Performance

```json
"processing": {
  "max_workers": 8,           // Match CPU core count
  "chunk_size": 2000         // Increase for better throughput
}
```

### Quality Control Performance

```json
"quality_control": {
  "thresholds": {
    "min_good_data_percentage": 60.0  // Lower for faster processing
  }
}
```

For more performance tips, see the main [README.md](../README.md) performance section.