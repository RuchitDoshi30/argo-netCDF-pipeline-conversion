#!/bin/bash
# Quick Setup Script for ARGO Pipeline (Linux/macOS)

echo "ARGO Data Pipeline Setup Script"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "\n${YELLOW}1. Checking Python installation...${NC}"
if command_exists python3; then
    python_version=$(python3 --version)
    echo -e "   ${GREEN}✓ Python found: $python_version${NC}"
    PYTHON_CMD="python3"
elif command_exists python; then
    python_version=$(python --version)
    echo -e "   ${GREEN}✓ Python found: $python_version${NC}"
    PYTHON_CMD="python"
else
    echo -e "   ${RED}✗ Python not found! Please install Python 3.8+${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. Checking PostgreSQL installation...${NC}"
if command_exists psql; then
    echo -e "   ${GREEN}✓ PostgreSQL found${NC}"
else
    echo -e "   ${RED}✗ PostgreSQL not found!${NC}"
    echo -e "   Install PostgreSQL:"
    echo -e "   Ubuntu/Debian: sudo apt install postgresql postgresql-contrib"
    echo -e "   macOS: brew install postgresql"
    exit 1
fi

echo -e "\n${YELLOW}3. Checking PostgreSQL service status...${NC}"
if systemctl is-active --quiet postgresql 2>/dev/null; then
    echo -e "   ${GREEN}✓ PostgreSQL service is running${NC}"
elif brew services list | grep postgresql | grep started >/dev/null 2>&1; then
    echo -e "   ${GREEN}✓ PostgreSQL service is running${NC}"
else
    echo -e "   ${YELLOW}⚠ Starting PostgreSQL service...${NC}"
    if command_exists systemctl; then
        sudo systemctl start postgresql
    elif command_exists brew; then
        brew services start postgresql
    fi
fi

echo -e "\n${YELLOW}4. Setting up Python virtual environment...${NC}"
if [ -d "venv" ]; then
    echo -e "   ${YELLOW}Virtual environment already exists${NC}"
else
    $PYTHON_CMD -m venv venv
    echo -e "   ${GREEN}✓ Virtual environment created${NC}"
fi

echo -e "\n${YELLOW}5. Activating virtual environment and installing dependencies...${NC}"
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo -e "   ${GREEN}✓ Dependencies installed${NC}"

echo -e "\n${YELLOW}6. Setting up PostgreSQL database...${NC}"
echo -n "Enter PostgreSQL postgres user password: "
read -s db_password
echo

# Create database and user
export PGPASSWORD="$db_password"

# Check if we can connect
if psql -U postgres -h localhost -c "\q" 2>/dev/null; then
    # Create database and user
    psql -U postgres -h localhost -c "CREATE DATABASE argo_data;" 2>/dev/null || true
    psql -U postgres -h localhost -c "CREATE USER argo_user WITH PASSWORD 'argo123';" 2>/dev/null || true
    psql -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE argo_data TO argo_user;" 2>/dev/null || true
    
    # Try to enable PostGIS
    if psql -U postgres -d argo_data -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null; then
        echo -e "   ${GREEN}✓ Database created with PostGIS extension${NC}"
    else
        echo -e "   ${YELLOW}✓ Database created (PostGIS not available - will use standard indexing)${NC}"
    fi
else
    echo -e "   ${RED}✗ Database setup failed. Please check PostgreSQL installation and password.${NC}"
    unset PGPASSWORD
    exit 1
fi

echo -e "\n${YELLOW}7. Creating configuration file...${NC}"
mkdir -p config

if [ ! -f "config/config.json" ]; then
    cp "config/config.template.json" "config/config.json"
    
    # Update password in config file
    sed -i.bak "s/\"password\": \"your_password_here\"/\"password\": \"$db_password\"/g" "config/config.json"
    rm "config/config.json.bak" 2>/dev/null || true
    
    echo -e "   ${GREEN}✓ Configuration file created and updated${NC}"
else
    echo -e "   ${YELLOW}Configuration file already exists${NC}"
fi

echo -e "\n${YELLOW}8. Creating required directories...${NC}"
directories=("logs" "temp" "reports")
for dir in "${directories[@]}"; do
    mkdir -p "$dir"
done
echo -e "   ${GREEN}✓ Required directories created${NC}"

echo -e "\n${YELLOW}9. Testing configuration...${NC}"
python3 -c "
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
unset PGPASSWORD

echo -e "\n${GREEN}🎉 Setup Complete!${NC}"
echo -e "\n${CYAN}Next steps:${NC}"
echo -e "${NC}1. Activate the virtual environment: source venv/bin/activate${NC}"  
echo -e "${NC}2. Run the pipeline: python src/argo_pipeline.py${NC}"
echo -e "${NC}3. View logs in the logs/ directory${NC}"
echo -e "\n${NC}For more information, see README.md${NC}"