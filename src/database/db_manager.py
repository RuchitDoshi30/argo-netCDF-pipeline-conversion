"""
Database Manager for ARGO Pipeline

Handles all database operations including schema setup and data storage.
"""

import psycopg2
import psycopg2.pool
from typing import Dict, Any, Optional
import logging
import json

logger = logging.getLogger(__name__)

class DatabaseManager:
    """
    Manages PostgreSQL database operations for ARGO data storage.
    """
    
    def __init__(self, config: Dict[str, Any]):
        """Initialize database manager with configuration."""
        self.config = config
        self.connection_pool = None
        self._setup_connection_pool()
    
    def _setup_connection_pool(self):
        """Setup database connection pool."""
        try:
            self.connection_pool = psycopg2.pool.ThreadedConnectionPool(
                minconn=1,
                maxconn=self.config.get('connection_pool_size', 10),
                host=self.config['host'],
                port=self.config.get('port', 5432),
                database=self.config['database'],
                user=self.config['user'],
                password=self.config['password']
            )
            logger.info("Database connection pool established")
        except Exception as e:
            logger.error(f"Failed to create database connection pool: {e}")
            raise
    
    def get_connection(self):
        """Get a connection from the pool."""
        if self.connection_pool:
            return self.connection_pool.getconn()
        return None
    
    def return_connection(self, conn):
        """Return a connection to the pool."""
        if self.connection_pool and conn:
            self.connection_pool.putconn(conn)
    
    def setup_database(self):
        """
        Setup database schema with all required tables and indexes.
        """
        conn = None
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            # Enable PostGIS if configured
            if self.config.get('enable_postgis', False):
                try:
                    cursor.execute("CREATE EXTENSION IF NOT EXISTS postgis;")
                    logger.info("PostGIS extension enabled")
                except Exception as e:
                    logger.warning(f"PostGIS not available: {e}")
            
            # Create main profiles table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS profiles (
                id SERIAL PRIMARY KEY,
                file_url TEXT UNIQUE NOT NULL,
                platform_number TEXT,
                cycle_number INTEGER,
                last_modified TIMESTAMP,
                juld DOUBLE PRECISION,
                latitude DOUBLE PRECISION,
                longitude DOUBLE PRECISION,
                data_quality VARCHAR(20),
                total_measurements INTEGER,
                good_data_percentage DOUBLE PRECISION,
                processing_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                -- Data arrays would be defined here
                metadata JSONB
            );
            """)
            
            # Create QC reports table
            cursor.execute("""
            CREATE TABLE IF NOT EXISTS qc_reports (
                id SERIAL PRIMARY KEY,
                profile_id INTEGER REFERENCES profiles(id) ON DELETE CASCADE,
                outliers_removed INTEGER DEFAULT 0,
                spike_detections INTEGER DEFAULT 0,
                gradient_anomalies INTEGER DEFAULT 0,
                density_inversions INTEGER DEFAULT 0,
                issues TEXT[],
                qc_metadata JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)
            
            # Create indexes
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_profiles_platform ON profiles (platform_number);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_profiles_quality ON profiles (data_quality);")
            cursor.execute("CREATE INDEX IF NOT EXISTS idx_profiles_location ON profiles (latitude, longitude);")
            
            conn.commit()
            logger.info("Database schema setup completed")
            
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error(f"Database setup failed: {e}")
            raise
        finally:
            if conn:
                self.return_connection(conn)
    
    def get_database_statistics(self) -> Dict[str, Any]:
        """
        Get database statistics for reporting.
        
        Returns:
            Dictionary containing database statistics
        """
        conn = None
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            # Get profile count
            cursor.execute("SELECT COUNT(*) FROM profiles;")
            total_records = cursor.fetchone()[0]
            
            # Get quality distribution
            cursor.execute("""
            SELECT data_quality, COUNT(*) 
            FROM profiles 
            GROUP BY data_quality;
            """)
            quality_dist = dict(cursor.fetchall())
            
            return {
                'total_records': total_records,
                'quality_distribution': quality_dist
            }
            
        except Exception as e:
            logger.error(f"Failed to get database statistics: {e}")
            return {}
        finally:
            if conn:
                self.return_connection(conn)
    
    def close(self):
        """Close all database connections."""
        if self.connection_pool:
            self.connection_pool.closeall()
            logger.info("Database connections closed")
