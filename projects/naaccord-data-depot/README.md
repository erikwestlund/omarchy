# NA Accord Data Depot - Local Development

## Quick Commands

| Alias | Command |
|-------|---------|
| `na` | cd to project |
| `bna` | Bootstrap (clone, build, start) |
| `lna` | Launch (VS Code + browser) |
| `kna` | Kill (stop Docker, close windows) |
| `tmna` | Launch tmux session |

## Database

### Connect to database

```bash
docker exec -it naaccord-test-mariadb mariadb -u naaccord -pI4ms3cr3t naaccord
```

### Run migrations

```bash
docker exec naaccord-test-web python manage.py migrate
```

## Services

| Service | URL/Port |
|---------|----------|
| App | http://naaccord.test |
| MariaDB | localhost:3310 |
| Redis | localhost:6393 |
| Mock-IDP | localhost:8082 |
| Flower | localhost:5555 |

## Frontend Assets

Run Vite locally (not in Docker):

```bash
cd ~/Projects/naaccord-data-depot && npm run dev
```

Build for production:

```bash
cd ~/Projects/naaccord-data-depot && npm run build
```

## Docker Commands

```bash
# View logs
docker logs -f naaccord-test-web

# Shell into web container
docker exec -it naaccord-test-web bash

# Restart all services
cd ~/Projects/naaccord-data-depot && docker compose restart
```

## Django Commands

```bash
# Create superuser
docker exec -it naaccord-test-web python manage.py createsuperuser

# Reseed initial data
docker exec naaccord-test-web python manage.py seed_init

# Load test users
docker exec naaccord-test-web python manage.py load_test_users
```
