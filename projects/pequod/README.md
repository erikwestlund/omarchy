# Pequod - Local Development

## Quick Commands

| Alias | Command |
|-------|---------|
| `peq` | cd to project |
| `bpeq` | Bootstrap (clone, build, start) |
| `lpeq` | Launch (VS Code + browser) |
| `kpeq` | Kill (stop Docker, close windows) |
| `tmpeq` | Launch tmux session |

## Database

### Restore from dump

```bash
docker exec -i pequod-postgres psql -U pequod -d pequod < ~/Projects/pequod/storage/app/dumps/pequod.sql
```

### Connect to database

```bash
docker exec -it pequod-postgres psql -U pequod -d pequod
```

## Services

| Service | URL/Port |
|---------|----------|
| App | http://academic.test |
| Vite | localhost:5173 |
| MinIO Console | http://localhost:9001 |
| Mailpit | http://localhost:8025 |
| PostgreSQL | localhost:5432 |
| Redis | localhost:6379 |

## Frontend Assets

Run Vite locally (not in Docker):

```bash
cd ~/Projects/pequod && npm run dev
```

Build for production:

```bash
cd ~/Projects/pequod && npm run build
```

## Docker Commands

```bash
# View logs
docker logs -f pequod-php

# Shell into PHP container
docker exec -it pequod-php sh

# Restart all services
cd ~/Projects/pequod && docker compose restart
```
