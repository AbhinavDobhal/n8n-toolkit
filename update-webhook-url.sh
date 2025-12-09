#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# Update n8n WEBHOOK_URL from ngrok tunnel
# ═══════════════════════════════════════════════════════════════════════════

set -e

echo "🔍 Fetching ngrok tunnel URL..."

# Wait for ngrok to be ready
sleep 2

# Get ngrok public URL from the API
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | grep -o 'https://[^"]*' | head -1)

if [ -z "$NGROK_URL" ]; then
    echo "❌ Failed to fetch ngrok URL. Make sure ngrok is running on http://localhost:4040"
    exit 1
fi

echo "✅ Found ngrok URL: $NGROK_URL"

# Update .env file
if [ -f ".env" ]; then
    # Check if WEBHOOK_URL exists
    if grep -q "WEBHOOK_URL=" .env; then
        # Update existing WEBHOOK_URL
        sed -i.bak "s|WEBHOOK_URL=.*|WEBHOOK_URL=$NGROK_URL|" .env
        rm -f .env.bak
        echo "✅ Updated WEBHOOK_URL in .env"
    else
        # Add new WEBHOOK_URL
        echo "WEBHOOK_URL=$NGROK_URL" >> .env
        echo "✅ Added WEBHOOK_URL to .env"
    fi
else
    echo "❌ .env file not found"
    exit 1
fi

echo "🔄 Restarting n8n with new webhook URL..."
docker compose restart n8n

echo "✅ Done! n8n is now using: $NGROK_URL"
