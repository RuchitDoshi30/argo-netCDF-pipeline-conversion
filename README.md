# ARGO NetCDF Pipeline Conversion

[![Python Version](https://img.shields.io/badge/python-3.8+-blue.svg)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-336791.svg)](https://postgresql.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A comprehensive, production-ready Python pipeline for downloading, processing, and quality-controlling ARGO oceanographic float data from the Indian Ocean region. This pipeline implements advanced data validation, statistical outlier detection, and provides robust PostgreSQL storage with optional PostGIS spatial capabilities.

## 🌊 Overview

The ARGO NetCDF Pipeline is designed to handle large-scale oceanographic data processing with enterprise-grade quality control. It processes data from the Global ARGO Program, focusing on the Indian Ocean region, and provides comprehensive data quality assessment and storage solutions.

### Key Features

- **🔍 Advanced Quality Control**: Multi-layered validation including spike detection, gradient analysis, and density inversion checks
- **🗄️ Robust Database Storage**: PostgreSQL with optional PostGIS spatial indexing for geographic queries
- **⚡ Parallel Processing**: Multi-threaded data download and processing for optimal performance
- **🛡️ Error Resilience**: Comprehensive retry logic and graceful error handling
- **📊 Data Analytics**: Built-in quality reporting and statistical analysis
- **🔧 Production Ready**: Comprehensive logging, monitoring, and configuration management

## 🚀 Quick Start

### Prerequisites

- **Python**: 3.8 or higher
- **PostgreSQL**: 12 or higher
- **PostGIS**: 3.0+ (optional but recommended)
- **System Memory**: 4GB+ RAM recommended

### Installation

#### Option 1: Automated Setup (Recommended)

**Windows (PowerShell as Administrator):**
```powershell
git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
cd argo-netCDF-pipeline-conversion
.\scripts\setup.ps1
```

**Linux/macOS:**
```bash
git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
cd argo-netCDF-pipeline-conversion
chmod +x scripts/setup.sh
./scripts/setup.sh
```

#### Option 2: Manual Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
   cd argo-netCDF-pipeline-conversion
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/macOS
   # or
   venv\Scripts\activate     # Windows
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Setup PostgreSQL database:**
   ```sql
   CREATE DATABASE argo_data;
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```

5. **Configure database connection:**
   ```bash
   cp config/config.template.json config/config.json
   # Edit config/config.json with your database credentials
   ```

### Running the Pipeline

```bash
# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate     # Windows

# Run the complete pipeline
python src/argo_pipeline.py

# Or run with custom configuration
python src/argo_pipeline.py --config config/custom_config.json
```

## 📋 Documentation

| Document | Description |
|----------|-------------|
| [Installation Guide](docs/INSTALLATION.md) | Detailed setup instructions for all platforms |
| [Configuration Guide](docs/CONFIGURATION.md) | Database and pipeline configuration options |
| [API Documentation](docs/API.md) | Function and class reference |
| [Quality Control Guide](docs/QUALITY_CONTROL.md) | QC algorithms and thresholds |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |
| [Contributing](CONTRIBUTING.md) | Guidelines for contributors |

## 🏗️ Architecture

```
argo-netCDF-pipeline-conversion/
├── src/
│   ├── argo_pipeline.py      # Main pipeline execution
│   ├── quality_control/      # QC algorithms and validators
│   ├── data_processing/      # NetCDF processing and conversion
│   ├── database/            # Database operations and schema
│   └── utils/               # Utility functions and helpers
├── scripts/
│   ├── setup.ps1            # Windows setup script
│   ├── setup.sh             # Linux/macOS setup script
│   └── maintenance/         # Database maintenance scripts
├── config/
│   ├── config.template.json # Configuration template
│   └── schemas/             # Database schema definitions
├── docs/                    # Comprehensive documentation
├── tests/                   # Unit and integration tests
└── examples/                # Usage examples and tutorials
```

## 📊 Data Quality Features

### Quality Control Algorithms

| Algorithm | Description | Configurable Thresholds |
|-----------|-------------|-------------------------|
| **Physical Limits** | Temperature (-2.5°C to 40°C), Salinity (2-42 PSU), Pressure (0-11000 dbar) | ✅ |
| **Statistical Outliers** | Modified Z-score method for anomaly detection | ✅ |
| **Spike Detection** | Multiple algorithms for identifying measurement spikes | ✅ |
| **Gradient Analysis** | Detection of unrealistic vertical gradients | ✅ |
| **Density Inversions** | Physical oceanography consistency checks | ✅ |

### Quality Categories

- **🟢 Excellent**: >90% good data, minimal quality issues
- **🔵 Good**: 80-90% good data, minor quality concerns  
- **🟡 Acceptable**: 70-80% good data, moderate quality issues
- **🟠 Poor**: 50-70% good data, significant quality problems
- **🔴 Unusable**: <50% good data, major quality failures

## 🔧 Configuration

### Database Configuration

```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "database": "argo_data",
    "user": "postgres",
    "password": "your_password",
    "connection_pool_size": 10,
    "enable_postgis": true
  }
}
```

### Processing Configuration

```json
{
  "processing": {
    "max_workers": 4,
    "chunk_size": 1000,
    "timeout_seconds": 30,
    "retry_attempts": 3,
    "quality_thresholds": {
      "min_good_data_percentage": 70.0,
      "max_outlier_percentage": 10.0
    }
  }
}
```

## 📈 Performance

### Benchmarks

| Operation | Performance | Memory Usage |
|-----------|-------------|--------------|
| **Single Profile Processing** | ~2-5 seconds | ~50MB |
| **Batch Processing (100 profiles)** | ~3-8 minutes | ~500MB |
| **Quality Control Analysis** | ~1-2 seconds per profile | ~20MB |
| **Database Storage** | ~500 profiles/minute | ~100MB |

### Optimization Tips

- **Parallel Processing**: Adjust `max_workers` based on CPU cores
- **Database Tuning**: Configure PostgreSQL shared_buffers and work_mem
- **Network**: Use stable, high-bandwidth connection for data downloads
- **Storage**: SSD recommended for database and temporary files

## 🧪 Testing

```bash
# Run all tests
python -m pytest tests/

# Run specific test categories
python -m pytest tests/unit/           # Unit tests
python -m pytest tests/integration/   # Integration tests
python -m pytest tests/quality/       # Quality control tests

# Run with coverage
python -m pytest --cov=src tests/
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone and setup development environment
git clone https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion.git
cd argo-netCDF-pipeline-conversion

# Install development dependencies
pip install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Run tests
python -m pytest
```

### Code Quality

- **Formatting**: We use [Black](https://black.readthedocs.io/) for code formatting
- **Linting**: [Flake8](https://flake8.pycqa.org/) for style guide enforcement
- **Type Checking**: [mypy](https://mypy.readthedocs.io/) for static type checking
- **Testing**: [pytest](https://pytest.org/) with comprehensive test coverage

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ARGO Program**: Global ARGO Program for providing oceanographic data
- **Ifremer**: French Research Institute for Exploitation of the Sea for data hosting
- **PostGIS Community**: For spatial database capabilities
- **Scientific Python Ecosystem**: NumPy, pandas, xarray, and related libraries

## 📬 Contact

- **Author**: Ruchit Doshi
- **GitHub**: [@RuchitDoshi30](https://github.com/RuchitDoshi30)
- **Project Issues**: [GitHub Issues](https://github.com/RuchitDoshi30/argo-netCDF-pipeline-conversion/issues)

## 🔗 Related Projects

- [ARGO Data Management](https://argo.ucsd.edu/)
- [Ocean Data View](https://odv.awi.de/)
- [PyARGO](https://github.com/euroargodev/argopy)

---

**⭐ If this project helped you, please consider giving it a star!**

Made with ❤️ for the oceanographic research community.