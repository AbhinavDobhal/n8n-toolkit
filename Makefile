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
	@echo "  make build-n8n      - Build custom n8n image (with ffmpeg)"
	@echo "  make rebuild-n8n    - Build and restart n8n service"
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
	@echo "🌐 Access your services LOCALLY at:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   n8n (Automation)     → http://localhost:5678"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "🌍 Access via NGROK TUNNEL (public URLs):"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   ngrok Dashboard      → http://localhost:4040"
	@echo "   (Public URLs visible in the dashboard above)"
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
	@echo "🌐 Access your services LOCALLY at:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   n8n (Automation)     → http://localhost:5678"
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
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "📝 Notes:"
	@echo "═══════════════════════════════════════════════════════════════════════════"
	@echo "   • From within Docker containers, use 'host.docker.internal' instead of"
	@echo "     'localhost' to access services on the host machine."
	@echo "   • For container-to-container communication, use service names:"
	@echo "     - n8n: http://n8n:5678"
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

# Build custom n8n image (with ffmpeg)
build-n8n:
	@echo "🔧 Building custom n8n image with ffmpeg..."
	docker compose build n8n

# Build and restart n8n
rebuild-n8n: build-n8n
	@echo "🔁 Restarting n8n service..."
	docker compose up -d n8n
	@echo "✅ n8n restarted (with ffmpeg)"
