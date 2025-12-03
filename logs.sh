#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - View Logs
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SERVICE=${1:-}

if [ -z "$SERVICE" ]; then
    echo "📋 Showing logs for all services (Ctrl+C to exit)..."
    echo ""
    docker compose logs -f
else
    echo "📋 Showing logs for $SERVICE (Ctrl+C to exit)..."
    echo ""
    docker compose logs -f "$SERVICE"
fi
