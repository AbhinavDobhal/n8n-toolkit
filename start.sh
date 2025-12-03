#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - Start Script
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Starting n8n Toolkit Stack..."
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found. Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ Created .env file. Please edit it with your configuration."
        echo ""
    else
        echo "❌ No .env.example file found. Please create a .env file."
        exit 1
    fi
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop first."
    exit 1
fi

echo "📦 Pulling latest images..."
docker compose pull

echo ""
echo "🔄 Starting services..."
docker compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 5

echo ""
echo "✅ All services started!"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "🌐 Access your services at:"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "   n8n (Automation)     → http://localhost:5678"
echo "   MinIO Console        → http://localhost:9001"
echo "   Kokoro TTS           → http://localhost:8880/web"
echo "   Baserow (Database)   → http://localhost:85"
echo "   NCA Toolkit API      → http://localhost:8080"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Useful commands:"
echo "   View logs:     docker compose logs -f"
echo "   Stop all:      ./stop.sh"
echo "   Status:        docker compose ps"
echo ""
