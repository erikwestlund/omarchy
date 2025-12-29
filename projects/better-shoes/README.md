# Better Shoes - Local Development

## Quick Commands

| Alias | Command |
|-------|---------|
| `bs` | cd to project |
| `bbs` | Bootstrap (clone, build, start) |
| `lbs` | Launch (VS Code + browser) |
| `kbs` | Kill (stop Docker, close windows) |
| `tmbs` | Launch tmux session |

## Database

### Restore from dump

```bash
docker exec -i better-shoes-postgres psql -U better_shoes -d better_shoes < ~/Projects/better-shoes/storage/app/dumps/better_shoes.sql
```

Or use the alias:

```bash
restore-bs better_shoes.sql
```

### Connect to database

```bash
docker exec -it better-shoes-postgres psql -U better_shoes -d better_shoes
```

## Services

| Service | URL/Port |
|---------|----------|
| App | http://better-shoes.test |
| Vite | localhost:5174 |
| Meilisearch | http://localhost:7700 |
| MinIO Console | http://localhost:9003 |
| Mailpit | http://localhost:8026 |
| PostgreSQL | localhost:5433 |
| Redis | localhost:6380 |

## Frontend Assets

Run Vite locally (not in Docker):

```bash
cd ~/Projects/better-shoes && npm run dev
```

Build for production:

```bash
cd ~/Projects/better-shoes && npm run build
```

## Docker Commands

```bash
# View logs
docker logs -f better-shoes-php

# Shell into PHP container
docker exec -it better-shoes-php sh

# Restart all services
cd ~/Projects/better-shoes && docker compose restart
```
