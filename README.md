# 🛠️ n8n Toolkit - Complete Automation Stack

A comprehensive Docker Compose setup for running a complete no-code automation stack including n8n workflow automation, MinIO object storage, Kokoro TTS, and Baserow database.

## 📋 Table of Contents

- [Overview](#-overview)
- [Services Included](#-services-included)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Service Details](#-service-details)
- [GPU Support for Kokoro TTS](#-gpu-support-for-kokoro-tts)
- [Accessing Services](#-accessing-services)
- [Troubleshooting](#-troubleshooting)
- [Useful Commands](#-useful-commands)

---

## 🎯 Overview

This toolkit provides a self-hosted automation stack that eliminates the need for multiple paid API subscriptions. It combines:

- **Workflow Automation** - Build complex automations with n8n
- **Object Storage** - S3-compatible storage with MinIO
- **Text-to-Speech** - High-quality TTS with Kokoro
- **Database UI** - No-code database management with Baserow

---

## 📦 Services Included

| Service | Description | Port |
|---------|-------------|------|
| **n8n** | Workflow automation platform | 5678 |
| **MinIO** | S3-compatible object storage | 9000 (API), 9001 (Console) |
| **Kokoro TTS** | Text-to-speech engine | 8880 |
| **Baserow** | No-code database platform | 85 |

---

## ✅ Prerequisites

1. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop/)
2. **Docker Compose** - Included with Docker Desktop
3. **Minimum System Requirements**:
   - 8GB RAM (16GB recommended)
   - 20GB free disk space
   - (Optional) NVIDIA GPU for GPU-accelerated TTS

---

## 🚀 Quick Start

### 1. Clone or Download

```bash
cd /path/to/your/projects
mkdir n8n-toolkit && cd n8n-toolkit
```

### 2. Create Environment File

```bash
cp .env.example .env
```

Edit `.env` and update the values:

```bash
# IMPORTANT: Change these for production!
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your_secure_password
```

### 3. Start All Services

```bash
docker compose up -d
```

### 4. Verify Services Are Running

```bash
docker compose ps
```

---

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WEBHOOK_URL` | `http://host.docker.internal:5678` | n8n webhook URL (change for VPS/custom domain) |
| `MINIO_ROOT_USER` | `admin` | MinIO admin username |
| `MINIO_ROOT_PASSWORD` | `password123` | MinIO admin password |
| `S3_BUCKET_NAME` | `nca-toolkit` | Default bucket name |
| `S3_REGION` | `None` | S3 region (use `None` for MinIO) |
| `BASEROW_PUBLIC_URL` | `http://host.docker.internal:85` | Baserow public URL |

---

## 📖 Service Details

### 🔄 n8n (Workflow Automation)

n8n is a powerful workflow automation tool that connects various services and APIs.

- **URL**: http://localhost:5678
- **Documentation**: https://docs.n8n.io/

**Features:**
- Visual workflow builder
- 400+ integrations
- Self-hosted & privacy-focused
- Webhook support

### 💾 MinIO (Object Storage)

MinIO provides S3-compatible object storage for all your files.

- **API URL**: http://localhost:9000
- **Console URL**: http://localhost:9001
- **Default Credentials**: admin / password123

**Initial Setup:**
The `minio-setup` container automatically creates the `nca-toolkit` bucket on first run.

### 🗣️ Kokoro TTS (Text-to-Speech)

High-quality text-to-speech synthesis.

- **URL**: http://localhost:8880
- **Web Interface**: http://localhost:8880/web

### 📋 Baserow (Database)

No-code database platform with a spreadsheet-like interface.

- **URL**: http://localhost:85
- **Documentation**: https://baserow.io/docs

---

## 🎮 GPU Support for Kokoro TTS

To enable GPU acceleration for Kokoro TTS:

1. Ensure you have an NVIDIA GPU with proper drivers
2. Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
3. Modify `docker-compose.yml`:

```yaml
kokoro-tts:
  image: ghcr.io/remsky/kokoro-fastapi-gpu:v0.2.2
  container_name: kokoro-tts
  restart: unless-stopped
  ports:
    - "8880:8880"
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: all
            capabilities: [gpu]
  networks:
    - n8n-toolkit-network
```

---

## 🌐 Accessing Services

| Service | URL |
|---------|-----|
| n8n | http://localhost:5678 |
| MinIO Console | http://localhost:9001 |
| MinIO API | http://localhost:9000 |
| Kokoro TTS Web | http://localhost:8880/web |
| Baserow | http://localhost:85 |

> **Note**: When accessing from within containers, use service names (e.g., `http://minio:9000`) or `host.docker.internal` for the host machine.

---

## 🔧 Troubleshooting

### Services Not Starting

```bash
# View logs for all services
docker compose logs

# View logs for specific service
docker compose logs n8n
```

### MinIO Bucket Not Created

```bash
# Manually create bucket
docker exec -it minio mc alias set myminio http://localhost:9000 admin password123
docker exec -it minio mc mb myminio/nca-toolkit
```

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`:

```yaml
ports:
  - "NEW_PORT:INTERNAL_PORT"
```

### Reset Everything

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Start fresh
docker compose up -d
```

---

## 📝 Useful Commands

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# View running containers
docker compose ps

# View logs (follow mode)
docker compose logs -f

# Restart a specific service
docker compose restart n8n

# Pull latest images
docker compose pull

# Remove all data and start fresh
docker compose down -v
docker compose up -d

# Execute command in container
docker exec -it n8n /bin/sh
```

---

## 📄 License

This project combines multiple open-source tools:
- **n8n**: [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md)
- **MinIO**: [GNU AGPL v3](https://github.com/minio/minio/blob/master/LICENSE)
- **Baserow**: [MIT License](https://gitlab.com/baserow/baserow/-/blob/master/LICENSE)
- **Kokoro TTS**: Check repository for license

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

---

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io/)
- [MinIO Documentation](https://min.io/docs/minio/container/index.html)
- [Baserow Documentation](https://baserow.io/docs)
- [Kokoro TTS GitHub](https://github.com/remsky/Kokoro-FastAPI)
