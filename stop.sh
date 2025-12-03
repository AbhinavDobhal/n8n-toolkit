#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - Stop Script
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🛑 Stopping n8n Toolkit Stack..."
echo ""

docker compose down

echo ""
echo "✅ All services stopped."
echo ""
echo "💡 Your data is preserved in Docker volumes."
echo "   To remove all data: ./reset.sh"
echo ""
