# ═══════════════════════════════════════════════════════════════════════════
# n8n Toolkit - Makefile
# ═══════════════════════════════════════════════════════════════════════════

.PHONY: help start stop restart logs status reset pull clean env endpoints

# Default target
help:
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "🛠️  n8n Toolkit - Available Commands"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "  make start      - Start all services"
	@echo "  make stop       - Stop all services"
	@echo "  make restart    - Restart all services"
	@echo "  make logs       - View logs for all services (Ctrl+C to exit)"
	@echo "  make status     - Show status of all services"
	@echo "  make endpoints  - Show all service endpoints and URLs"
	@echo "  make pull       - Pull latest Docker images"
	@echo "  make env        - Create .env file from .env.example"
	@echo "  make reset      - Stop and remove all containers and volumes (DESTRUCTIVE)"
	@echo "  make clean      - Remove stopped containers and unused images"
	@echo ""
	@echo "  make logs-n8n       - View n8n logs"
	@echo "  make logs-minio     - View MinIO logs"
	@echo "  make logs-baserow   - View Baserow logs"
	@echo "  make logs-tts       - View Kokoro TTS logs"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""

# Create .env file if it doesn't exist
env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Created .env file from .env.example"; \
		echo "📝 Please edit .env with your configuration"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

# Pull latest images
pull:
	@echo "📦 Pulling latest Docker images..."
	docker compose pull

# Start all services
start: env
	@echo "🚀 Starting n8n Toolkit Stack..."
	docker compose up -d --remove-orphans
	@echo ""
	@echo "✅ All services started!"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "🌐 Access your services at:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   n8n (Automation)     → http://localhost:5678"
	@echo "   MinIO Console        → http://localhost:9001"
	@echo "   Kokoro TTS           → http://localhost:8880/web"
	@echo "   Baserow (Database)   → http://localhost:85"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "💡 Run 'make endpoints' for detailed API endpoints"
	@echo ""

# Stop all services
stop:
	@echo "🛑 Stopping n8n Toolkit Stack..."
	docker compose down
	@echo "✅ All services stopped."

# Restart all services
restart:
	@echo "🔄 Restarting n8n Toolkit Stack..."
	docker compose down --remove-orphans
	docker compose up -d --remove-orphans
	@echo ""
	@echo "✅ All services restarted!"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════" 
	@echo "🌐 Access your services at:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   n8n (Automation)     → http://localhost:5678"
	@echo "   MinIO Console        → http://localhost:9001"
	@echo "   Kokoro TTS           → http://localhost:8880/web"
	@echo "   Baserow (Database)   → http://localhost:85"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "💡 Run 'make endpoints' for detailed API endpoints"
	@echo ""

# View logs for all services
logs:
	@echo "📋 Showing logs for all services (Ctrl+C to exit)..."
	docker compose logs -f

# Service-specific logs
logs-n8n:
	docker compose logs -f n8n

logs-minio:
	docker compose logs -f minio

logs-baserow:
	docker compose logs -f baserow

logs-tts:
	docker compose logs -f kokoro-tts

# Show status
status:
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "📊 n8n Toolkit Status"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@docker compose ps
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "🌐 Service URLs"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   n8n (Automation)     → http://localhost:5678"
	@echo "   MinIO Console        → http://localhost:9001"
	@echo "   Kokoro TTS           → http://localhost:8880/web"
	@echo "   Baserow (Database)   → http://localhost:85"
	@echo ""

# Show all endpoints
endpoints:
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "🌐 n8n Toolkit - Service Endpoints"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "┌─────────────────────────────────────────────────────────────────────────┐"
	@echo "│ 🔄 n8n - Workflow Automation                                            │"
	@echo "├─────────────────────────────────────────────────────────────────────────┤"
	@echo "│ Web UI:        http://localhost:5678                                    │"
	@echo "│ Webhooks:      http://localhost:5678/webhook/                           │"
	@echo "│ REST API:      http://localhost:5678/api/v1/                            │"
	@echo "└─────────────────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "┌─────────────────────────────────────────────────────────────────────────┐"
	@echo "│ 💾 MinIO - S3-Compatible Object Storage                                 │"
	@echo "├─────────────────────────────────────────────────────────────────────────┤"
	@echo "│ Console:       http://localhost:9001                                    │"
	@echo "│ S3 API:        http://localhost:9000                                    │"
	@echo "│ Health:        http://localhost:9000/minio/health/live                  │"
	@echo "│ Bucket URL:    http://localhost:9000/storage/                       │"
	@echo "│                                                                         │"
	@echo "│ Default Credentials:                                                    │"
	@echo "│   Username: admin                                                       │"
	@echo "│   Password: password123                                                 │"
	@echo "└─────────────────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "┌─────────────────────────────────────────────────────────────────────────┐"
	@echo "│ 🗣️  Kokoro TTS - Text-to-Speech                                         │"
	@echo "├─────────────────────────────────────────────────────────────────────────┤"
	@echo "│ Web UI:        http://localhost:8880/web                                │"
	@echo "│ API Docs:      http://localhost:8880/docs                               │"
	@echo "│ OpenAPI:       http://localhost:8880/openapi.json                       │"
	@echo "│                                                                         │"
	@echo "│ API Endpoints:                                                          │"
	@echo "│   POST /v1/audio/speech     - Generate speech from text                 │"
	@echo "│   GET  /v1/models           - List available voices                     │"
	@echo "│   GET  /v1/voices           - List voice options                        │"
	@echo "└─────────────────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "┌─────────────────────────────────────────────────────────────────────────┐"
	@echo "│ 📋 Baserow - No-Code Database                                           │"
	@echo "├─────────────────────────────────────────────────────────────────────────┤"
	@echo "│ Web UI:        http://localhost:85                                      │"
	@echo "│ API Docs:      http://localhost:85/api/redoc/                           │"
	@echo "│ REST API:      http://localhost:85/api/                                 │"
	@echo "│                                                                         │"
	@echo "│ API Endpoints:                                                          │"
	@echo "│   GET  /api/database/rows/table/{id}/    - List rows                    │"
	@echo "│   POST /api/database/rows/table/{id}/    - Create row                   │"
	@echo "│   GET  /api/database/tables/{id}/        - Get table info               │"
	@echo "└─────────────────────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "📝 Notes:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   • From within Docker containers, use 'host.docker.internal' instead of"
	@echo "     'localhost' to access services on the host machine."
	@echo "   • For container-to-container communication, use service names:"
	@echo "     - n8n: http://n8n:5678"
	@echo "     - MinIO: http://minio:9000"
	@echo "     - Kokoro TTS: http://kokoro-tts:8880"
	@echo "     - Baserow: http://baserow:80"
	@echo ""

# Reset everything (DESTRUCTIVE)
reset:
	@echo "⚠️  WARNING: This will delete ALL data and volumes!"
	@echo ""
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo ""
	@echo "🗑️  Stopping and removing all containers, networks, and volumes..."
	docker compose down -v
	@echo ""
	@echo "✅ Reset complete. Run 'make start' to start fresh."

# Clean up unused resources
clean:
	@echo "🧹 Cleaning up unused Docker resources..."
	docker compose down --remove-orphans
	docker system prune -f
	@echo "✅ Cleanup complete."
