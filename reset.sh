#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - Reset Script (DESTRUCTIVE)
# ═══════════════════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "⚠️  WARNING: This will delete ALL data and volumes!"
echo ""
echo "This includes:"
echo "  - n8n workflows and credentials"
echo "  - MinIO stored files"
echo "  - Baserow databases"
echo "  - NCA Toolkit temporary files"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo "❌ Reset cancelled."
    exit 0
fi

echo ""
echo "🗑️  Stopping and removing all containers, networks, and volumes..."
docker compose down -v

echo ""
echo "✅ Reset complete. All data has been removed."
echo ""
echo "💡 Run ./start.sh to start fresh."
echo ""
