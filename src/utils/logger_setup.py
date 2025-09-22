"""
Logger Setup Utility for ARGO Pipeline

Configures logging with appropriate handlers and formatters.
"""

import logging
import logging.handlers
import os
from typing import Dict, Any

def setup_logging(config: Dict[str, Any] = None) -> logging.Logger:
    """
    Setup logging configuration for the ARGO pipeline.
    
    Args:
        config: Logging configuration dictionary
        
    Returns:
        Configured logger instance
    """
    if config is None:
        config = {}
    
    # Get configuration values with defaults
    log_level = config.get('level', 'INFO')
    log_format = config.get('format', '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    log_file = config.get('file', 'logs/argo_pipeline.log')
    max_file_size = config.get('max_file_size', '10MB')
    backup_count = config.get('backup_count', 5)
    
    # Create logs directory if it doesn't exist
    log_dir = os.path.dirname(log_file)
    if log_dir and not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    # Setup root logger
    logger = logging.getLogger('argo_pipeline')
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Remove existing handlers
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)
    
    # Create formatter
    formatter = logging.Formatter(log_format)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(getattr(logging, log_level.upper()))
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # File handler with rotation
    if log_file:
        # Parse max file size
        size_value = int(max_file_size.replace('MB', '').replace('KB', '').replace('GB', ''))
        if 'KB' in max_file_size:
            max_bytes = size_value * 1024
        elif 'GB' in max_file_size:
            max_bytes = size_value * 1024 * 1024 * 1024
        else:  # Default to MB
            max_bytes = size_value * 1024 * 1024
        
        file_handler = logging.handlers.RotatingFileHandler(
            log_file,
            maxBytes=max_bytes,
            backupCount=backup_count
        )
        file_handler.setLevel(getattr(logging, log_level.upper()))
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    
    return logger
