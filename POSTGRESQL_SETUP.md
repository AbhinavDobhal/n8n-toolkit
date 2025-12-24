# PostgreSQL Connection for n8n - Setup Complete ✅

## Configuration Summary

Your n8n is now configured to use **PostgreSQL** instead of SQLite.

### Database Credentials:
```
Host: postgres (or localhost:5432 from host machine)
User: root
Password: root
Database: n8n
Port: 5432
```

## Starting Services

```bash
# Start all services
make start

# Or directly
docker-compose up -d
```

## Verify PostgreSQL Connection

### 1️⃣ Check Container Status
```bash
docker-compose ps
# Should show:
# - postgres    (Up and healthy)
# - n8n         (Up)
# - minio       (Up)
# - other services
```

### 2️⃣ Check n8n Logs
```bash
docker-compose logs n8n | tail -50
# Look for messages indicating successful DB connection:
# "DB connection string" or "successfully connected"
```

### 3️⃣ Connect to PostgreSQL Directly (Optional)
```bash
# From your host machine
psql -h localhost -U root -d n8n

# Inside the container
docker exec -it postgres psql -U root -d n8n
```

### 4️⃣ Access n8n Web UI
```
http://localhost:5678
Username: admin
Password: password123
```

## Database Files Location

- **Volume Name**: `n8n-toolkit_postgres-data`
- **Docker Volume Location**: `/var/lib/postgresql/data`
- **Check size**: `docker volume inspect n8n-toolkit_postgres-data`

## Connection Details in docker-compose.yml

The n8n container now has these environment variables:
```yaml
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=root
DB_POSTGRESDB_PASSWORD=root
DB_POSTGRESDB_SCHEMA=public
```

## Troubleshooting

### PostgreSQL won't start
```bash
# Check postgres logs
docker-compose logs postgres

# Verify database volume
docker volume ls | grep postgres

# If corrupted, remove and recreate
docker volume rm n8n-toolkit_postgres-data
docker-compose up -d postgres
```

### n8n can't connect to PostgreSQL
```bash
# Test connection from n8n container
docker exec -it n8n psql -h postgres -U root -d n8n

# Check if postgres service is healthy
docker-compose ps postgres
# Should show "healthy" status
```

### Port 5432 already in use
```bash
# Change port in docker-compose.yml
# Change: "5432:5432" to "5433:5432"
# Then connect with: psql -h localhost -p 5433
```

## Backup & Recovery

PostgreSQL data is persisted in the `postgres-data` volume. Your data will survive container restarts.

```bash
# Backup PostgreSQL database
docker exec -t postgres pg_dump -U root n8n | gzip > n8n-db-backup.sql.gz

# Restore from backup
gunzip < n8n-db-backup.sql.gz | docker exec -i postgres psql -U root -d n8n
```

## Performance Tips

1. **Keep containers in same network**: ✅ (Already configured)
2. **Use pg_isready health check**: ✅ (Already configured)
3. **Connection pooling**: Consider adding PgBouncer for production
4. **Backups**: Set up automated PostgreSQL backups

## What's New

- ✅ PostgreSQL database instead of SQLite
- ✅ Better data integrity and concurrency
- ✅ Easier backups and recovery
- ✅ Suitable for production workloads
- ✅ Health checks configured

## Next Steps

1. Start services: `make start`
2. Access n8n: `http://localhost:5678`
3. Verify PostgreSQL connection in logs
4. Create workflows and data will be stored in PostgreSQL

---

**Questions?** Check the logs: `docker-compose logs -f`
