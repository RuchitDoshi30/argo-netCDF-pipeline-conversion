"""
Configuration Loader for ARGO Pipeline

Handles loading and validation of configuration files.
"""

import json
import os
from typing import Dict, Any
import logging

logger = logging.getLogger(__name__)

class ConfigLoader:
    """
    Utility class for loading and validating configuration files.
    """
    
    @staticmethod
    def load_config(config_path: str) -> Dict[str, Any]:
        """
        Load configuration from JSON file.
        
        Args:
            config_path: Path to configuration file
            
        Returns:
            Configuration dictionary
            
        Raises:
            FileNotFoundError: If config file doesn't exist
            ValueError: If config file is invalid
        """
        if not os.path.exists(config_path):
            # Try to find template if main config doesn't exist
            template_path = config_path.replace('.json', '.template.json')
            if os.path.exists(template_path):
                logger.warning(f"Configuration file {config_path} not found. "
                             f"Please copy {template_path} to {config_path} and update it.")
            raise FileNotFoundError(f"Configuration file not found: {config_path}")
        
        try:
            with open(config_path, 'r') as f:
                config = json.load(f)
            
            # Validate required sections
            required_sections = ['database', 'data_source', 'processing']
            for section in required_sections:
                if section not in config:
                    raise ValueError(f"Missing required configuration section: {section}")
            
            # Validate database config
            db_config = config['database']
            required_db_fields = ['host', 'database', 'user', 'password']
            for field in required_db_fields:
                if field not in db_config:
                    raise ValueError(f"Missing required database field: {field}")
            
            logger.info(f"Configuration loaded successfully from {config_path}")
            return config
            
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON in configuration file: {e}")
        except Exception as e:
            raise ValueError(f"Error loading configuration: {e}")
    
    @staticmethod
    def validate_config(config: Dict[str, Any]) -> bool:
        """
        Validate configuration dictionary.
        
        Args:
            config: Configuration dictionary to validate
            
        Returns:
            True if valid, raises ValueError if invalid
        """
        # Additional validation logic would go here
        return True
