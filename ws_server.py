import argparse
import logging
import os
import uvicorn
from datetime import datetime

from ii_agent.server.app import create_app

# Configure logging for Railway
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    """Main entry point for the WebSocket server."""
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description="WebSocket Server for interacting with the Agent"
    )
    parser.add_argument(
        "--host",
        type=str,
        default=os.environ.get("HOST", "0.0.0.0"),
        help="Host to run the server on",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=int(os.environ.get("PORT", 8000)),
        help="Port to run the server on",
    )
    args = parser.parse_args()

    # Create the FastAPI app
    app = create_app()
    
    # Add health check endpoint for Railway
    @app.get("/health")
    async def health_check():
        """Health check endpoint for Railway deployment."""
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "service": "ii-agent-backend",
            "version": "1.0.0"
        }
    
    # Add root endpoint
    @app.get("/")
    async def root():
        """Root endpoint."""
        return {
            "message": "II-Agent Backend API",
            "status": "running",
            "docs": "/docs",
            "health": "/health"
        }

    # Environment info
    environment = os.environ.get("ENVIRONMENT", "development")
    debug = os.environ.get("DEBUG", "false").lower() == "true"
    
    logger.info(f"Starting II-Agent WebSocket server")
    logger.info(f"Environment: {environment}")
    logger.info(f"Debug mode: {debug}")
    logger.info(f"Host: {args.host}:{args.port}")
    
    # Start the FastAPI server
    uvicorn.run(
        app, 
        host=args.host, 
        port=args.port,
        log_level="info" if not debug else "debug",
        access_log=True
    )


if __name__ == "__main__":
    main()