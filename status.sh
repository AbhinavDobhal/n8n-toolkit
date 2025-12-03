#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - Status Script
# ═══════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "═══════════════════════════════════════════════════════════════════════════"
echo "📊 n8n Toolkit Status"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

docker compose ps

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "💾 Volume Usage"
echo "═══════════════════════════════════════════════════════════════════════════"
echo ""

docker system df -v 2>/dev/null | grep -E "(n8n|minio|baserow|nca)" || echo "No volumes found"

echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "🌐 Service URLs"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "   n8n (Automation)     → http://localhost:5678"
echo "   MinIO Console        → http://localhost:9001"
echo "   Kokoro TTS           → http://localhost:8880/web"
echo "   Baserow (Database)   → http://localhost:85"
echo "   NCA Toolkit API      → http://localhost:8080"
echo ""
