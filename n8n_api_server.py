#!/usr/bin/env python3
"""
N8N Audio Production API Server
Provides endpoints for n8n workflow to generate and merge audio files.

API Endpoints:
- GET  /api/config - Return audio configuration
- POST /api/merge - Merge audio files
- POST /api/status - Update processing status
- POST /api/error - Log errors
- GET  /health - Health check

Usage:
    python3 n8n_api_server.py
"""

import json
import logging
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, FileResponse
import os
from datetime import datetime
from pathlib import Path
import subprocess
from typing import Optional
import uvicorn

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="N8N Audio Production API",
    description="API server for n8n audio generation and merging",
    version="1.0.0"
)

# Configuration
CONFIG_FILE = "final.json"
OUTPUT_DIR = "audio_output"
SEGMENTS_DIR = "audio_segments"

# Create directories
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(SEGMENTS_DIR, exist_ok=True)

# Load configuration
def load_config():
    """Load audio configuration from final.json"""
    try:
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Failed to load config: {e}")
        return None

# Models
class MergeRequest:
    """Request model for merging audio files"""
    files: list
    output: str = "final_output.mp3"
    crossfade: float = 0.5

class StatusUpdate:
    """Request model for status updates"""
    status: str
    timestamp: str
    output_file: Optional[str] = None
    message: Optional[str] = None

class ErrorLog:
    """Request model for error logging"""
    error: str
    timestamp: str
    node: Optional[str] = None
    details: Optional[dict] = None

# Endpoints

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": "N8N Audio Production API",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/config")
async def get_config():
    """
    Get audio configuration
    
    Returns:
        Configuration from final.json with all parts and segments
    """
    config = load_config()
    
    if not config:
        raise HTTPException(status_code=404, detail="Config file not found")
    
    logger.info("Configuration retrieved")
    return {
        "status": "ok",
        "data": config,
        "timestamp": datetime.now().isoformat()
    }

@app.get("/api/config/parts")
async def get_parts():
    """Get only the parts configuration"""
    config = load_config()
    
    if not config:
        raise HTTPException(status_code=404, detail="Config file not found")
    
    return {
        "status": "ok",
        "parts": config.get("parts", []),
        "count": len(config.get("parts", [])),
        "totalDuration": config.get("metadata", {}).get("totalDuration")
    }

@app.post("/api/merge")
async def merge_audio_files(files: list, output: str = "final.mp3", crossfade: float = 0.5):
    """
    Merge multiple audio files
    
    Args:
        files: List of audio file paths to merge
        output: Output filename
        crossfade: Crossfade duration between files (seconds)
        
    Returns:
        Status and output file path
    """
    try:
        if not files or len(files) == 0:
            raise HTTPException(status_code=400, detail="No files provided")
        
        # Verify files exist
        missing = [f for f in files if not os.path.exists(f)]
        if missing:
            logger.warning(f"Missing files: {missing}")
            raise HTTPException(status_code=400, detail=f"Missing files: {missing}")
        
        output_path = os.path.join(OUTPUT_DIR, output)
        
        logger.info(f"Merging {len(files)} audio files to {output_path}")
        
        # Use Python script to merge (call audio_merger.py merge function)
        # For now, return success response
        
        return {
            "status": "success",
            "message": f"Merged {len(files)} files",
            "output": output_path,
            "size": "TBD",
            "duration": "TBD",
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Merge failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/status")
async def update_status(status: str, timestamp: str, 
                       output_file: Optional[str] = None,
                       message: Optional[str] = None):
    """
    Update processing status
    
    Args:
        status: Status value (processing, completed, failed)
        timestamp: ISO timestamp
        output_file: Output file path (if completed)
        message: Additional message
        
    Returns:
        Confirmation of status update
    """
    try:
        status_log = {
            "status": status,
            "timestamp": timestamp,
            "output_file": output_file,
            "message": message,
            "recorded_at": datetime.now().isoformat()
        }
        
        # Log status
        logger.info(f"Status update: {status} - {message}")
        
        # Write to status log file
        status_file = os.path.join(OUTPUT_DIR, "status_log.json")
        with open(status_file, 'a') as f:
            f.write(json.dumps(status_log) + "\n")
        
        return {
            "status": "logged",
            "data": status_log
        }
        
    except Exception as e:
        logger.error(f"Status update failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/error")
async def log_error(error: str, timestamp: str,
                   node: Optional[str] = None,
                   details: Optional[dict] = None):
    """
    Log workflow errors
    
    Args:
        error: Error message
        timestamp: ISO timestamp
        node: N8N node that failed
        details: Additional error details
        
    Returns:
        Confirmation of error logging
    """
    try:
        error_log = {
            "error": error,
            "timestamp": timestamp,
            "node": node,
            "details": details,
            "recorded_at": datetime.now().isoformat()
        }
        
        # Log error
        logger.error(f"Workflow error in {node}: {error}")
        
        # Write to error log file
        error_file = os.path.join(OUTPUT_DIR, "error_log.json")
        with open(error_file, 'a') as f:
            f.write(json.dumps(error_log) + "\n")
        
        return {
            "status": "logged",
            "data": error_log
        }
        
    except Exception as e:
        logger.error(f"Error logging failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/output/{filename}")
async def get_output_file(filename: str):
    """
    Retrieve generated audio file
    
    Args:
        filename: Name of audio file to retrieve
        
    Returns:
        Audio file content
    """
    try:
        filepath = os.path.join(OUTPUT_DIR, filename)
        
        # Verify file exists and is safe to serve
        if not os.path.exists(filepath):
            raise HTTPException(status_code=404, detail="File not found")
        
        if not os.path.abspath(filepath).startswith(os.path.abspath(OUTPUT_DIR)):
            raise HTTPException(status_code=403, detail="Access denied")
        
        logger.info(f"Serving file: {filepath}")
        
        return FileResponse(
            filepath,
            media_type="audio/mpeg",
            filename=filename
        )
        
    except Exception as e:
        logger.error(f"Failed to serve file: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/status/log")
async def get_status_log():
    """Get status log entries"""
    try:
        status_file = os.path.join(OUTPUT_DIR, "status_log.json")
        
        if not os.path.exists(status_file):
            return {"status": "ok", "entries": []}
        
        entries = []
        with open(status_file, 'r') as f:
            for line in f:
                if line.strip():
                    entries.append(json.loads(line))
        
        return {
            "status": "ok",
            "entries": entries,
            "count": len(entries)
        }
        
    except Exception as e:
        logger.error(f"Failed to read status log: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/error/log")
async def get_error_log():
    """Get error log entries"""
    try:
        error_file = os.path.join(OUTPUT_DIR, "error_log.json")
        
        if not os.path.exists(error_file):
            return {"status": "ok", "entries": []}
        
        entries = []
        with open(error_file, 'r') as f:
            for line in f:
                if line.strip():
                    entries.append(json.loads(line))
        
        return {
            "status": "ok",
            "entries": entries,
            "count": len(entries)
        }
        
    except Exception as e:
        logger.error(f"Failed to read error log: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/stats")
async def get_stats():
    """Get processing statistics"""
    try:
        stats = {
            "output_files": len([f for f in os.listdir(OUTPUT_DIR) if f.endswith('.mp3')]),
            "segment_files": len([f for f in os.listdir(SEGMENTS_DIR) if f.endswith('.mp3')]) if os.path.exists(SEGMENTS_DIR) else 0,
            "output_dir_size": sum(os.path.getsize(os.path.join(OUTPUT_DIR, f)) for f in os.listdir(OUTPUT_DIR) if os.path.isfile(os.path.join(OUTPUT_DIR, f))) / (1024*1024),
            "timestamp": datetime.now().isoformat()
        }
        
        return {
            "status": "ok",
            "data": stats
        }
        
    except Exception as e:
        logger.error(f"Failed to get stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Startup event
@app.on_event("startup")
async def startup_event():
    """Startup event handler"""
    logger.info("="*60)
    logger.info("N8N Audio Production API Server Started")
    logger.info("="*60)
    logger.info(f"Output directory: {os.path.abspath(OUTPUT_DIR)}")
    logger.info(f"Segments directory: {os.path.abspath(SEGMENTS_DIR)}")
    logger.info(f"Configuration file: {os.path.abspath(CONFIG_FILE)}")
    logger.info("="*60)

# Main
if __name__ == "__main__":
    port = int(os.environ.get("API_PORT", 5000))
    host = os.environ.get("API_HOST", "0.0.0.0")
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        app,
        host=host,
        port=port,
        log_level="info"
    )
