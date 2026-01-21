# Omarchy Project Launcher System

Documentation for the project launcher system used to quickly open development environments.

## Overview

The project launcher system provides a standardized way to launch development projects with proper workspace management, Docker service orchestration, and automatic window positioning. Each project has a set of launcher scripts that handle environment setup, window management, and cleanup.

## Project Structure

Each project directory contains:

```
project-name/
├── launch          # Main launcher script
├── kill            # Stop script (closes windows, stops Docker)
├── bootstrap       # One-time setup (clone repo, copy secrets, build Docker images)
├── tmux.sh         # Terminal multiplexer configuration
└── *.code-workspace # VS Code workspace file
```

## Launch Script Behavior

### Desktop vs Laptop Modes

The launcher adapts based on the machine type (detected via `~/.machine`):

**Desktop Mode:**
- Browser and editor open on the **same workspace**
- Browser opens **first** (positioned on right side)
- Editor opens **second** (positioned on left side)
- Both windows remain on the target workspace

**Laptop Mode:**
- Editor opens on **workspace N**
- Browser opens on **workspace N+1** (next workspace)
- Automatically switches back to workspace N after opening
- Provides separation between code and browser on smaller screens

### Launch Flow

1. **Notification**: "Launching..." appears
2. **Workspace Switch**: Switches to target workspace (default: WS 1)
3. **Docker Services** (if enabled):
   - Shows "Starting Docker services..." notification
   - Runs `docker compose up -d`
   - Waits for health checks on all services (Redis, Postgres, etc.)
   - Shows "Waiting for services..." only if startup takes >4 seconds
4. **Window Opening**:
   - **Desktop**: Browser → Editor (both on same WS)
   - **Laptop**: Editor on WS N → Browser on WS N+1 → Return to WS N
5. **Race Condition Prevention**: Waits for each window to actually appear before proceeding
6. **Completion**: "Ready! Workspace X" notification

### Notification Flow

All notifications auto-close:
1. "Launching..." (5s)
2. "Starting Docker services..." (4s) - only if Docker enabled
3. "Waiting for services..." (10s) - only if services take >4s
4. "Ready! Workspace X" (3s)

### Docker Health Check Waiting

The launcher waits up to 60 seconds for Docker services to report healthy status before opening windows. This prevents:
- "Connection refused" errors (e.g., Redis, Postgres)
- Opening the browser before the application is ready
- Race conditions between service startup and app loading

Services with health checks (example from pequod):
- PostgreSQL (`pg_isready`)
- Redis (`redis-cli ping`)
- MinIO (`curl health endpoint`)

### Window Positioning Logic

**Desktop Mode Implementation:**
```bash
# Browser opens first with workspace dispatcher
hyprctl dispatch exec "[workspace $WS silent]" "chromium --new-window '$URL'"

# Wait for browser window to appear on workspace
for i in {1..10}; do
    if has_window_on_ws "$WS" "chromium"; then
        break
    fi
    sleep 0.2
done

# Editor opens second
hyprctl dispatch exec "[workspace $WS silent]" "$EDITOR '$WORKSPACE_FILE'"
```

**Laptop Mode Implementation:**
```bash
# Switch to editor workspace and open
hyprctl dispatch workspace $WS
$EDITOR "$WORKSPACE_FILE" &

# Wait for editor window to appear before switching
for i in {1..20}; do
    if has_window_on_ws "$WS" "code"; then
        break
    fi
    sleep 0.2
done

# Switch to browser workspace, open browser
BROWSER_WS=$((WS + 1))
hyprctl dispatch workspace $BROWSER_WS
chromium --new-window "$VIEW_URL" &

# Wait for browser to appear
for i in {1..20}; do
    if has_window_on_ws "$BROWSER_WS" "chromium"; then
        break
    fi
    sleep 0.2
done

# Return to editor workspace
hyprctl dispatch workspace $WS
```

The waiting loops prevent race conditions where window creation is delayed and windows end up on the wrong workspace.

## Command Aliases

Projects generate command aliases (configured via `~/Omarchy/config/projects/projects.yml`):

| Alias | Purpose | Example |
|-------|---------|---------|
| `l{alias}` | Launch project | `lpeq` launches pequod |
| `k{alias}` | Kill project | `kpeq` stops pequod |
| `tm{alias}` | Launch tmux only | `tmpeq` opens terminal session |
| `b{alias}` | Bootstrap project | `bpeq` sets up pequod |
| `pm{alias}` | cd to project config | `pmpeq` → `~/Omarchy/projects/pequod` |
| `{alias}` | cd to project code | `peq` → `~/Projects/pequod` |
| `d{alias}` | Docker compose up | `dpeq` starts Docker services |
| `dd{alias}` | Docker compose down | `ddpeq` stops Docker services |

## Configuration

Project configuration is managed in `~/Omarchy/config/projects/projects.yml`:

```yaml
projects:
  - name: pequod
    alias: peq
    type: laravel          # laravel, python, rstats, utility
    path: ~/Projects/pequod
    extras:
      view_url: http://academic.test/admin
      default_ws: 1
```

## Bootstrap Script

The `bootstrap` script handles one-time project setup:

1. **Repository Cloning**: Clones from Git if not present
2. **Secrets Management**: Copies secrets from `~/.secrets/{project}/` to project directory
3. **Docker Build**: Builds Docker images if `docker-compose.yml` exists

Example usage:
```bash
bpeq  # Bootstrap pequod project
```

## Kill Script

The `kill` script provides clean shutdown:

1. Stops Docker services (`docker compose down`)
2. Closes project windows (editor and browser)
3. Returns workspace to clean state

Example usage:
```bash
kpeq  # Stop pequod project
```

## Port Allocation System

All ports are tracked in `~/Omarchy/config/projects/projects.yml`. The `pm-new` script auto-assigns next available ports.

### Base Ports (Convention)
```
vite:           5173+
nginx:          8010+
postgres:       5440+
redis:          6390+
meilisearch:    7700+
minio_api:      9010+
minio_console:  9011+
mailpit_smtp:   1030+
mailpit_web:    8030+
mariadb:        3310+
```

### Port Configuration Locations

Ports must be consistent across THREE locations:

1. **projects.yml** - Source of truth for `pm-new` to find next available
2. **Caddy config** - `~/Omarchy/ansible/roles/caddy/defaults/main.yml` (dev_sites)
3. **docker-compose.yml** - Generated by bootstrap or manually created
4. **vite.config.js** - For Vite dev server (must match projects.yml)

### Vite Configuration Requirements

All projects with Vite MUST have:
```javascript
server: {
    port: XXXX,           // From projects.yml
    strictPort: true,     // REQUIRED: Fail if port busy, don't switch
    // For projects behind Caddy proxy:
    allowedHosts: ['myproject.test'],
}
```

## Project Type Requirements

### Laravel Projects (`type: laravel`)

**Services (Docker):**
- `php` - PHP-FPM container
- `nginx` - Web server (port from projects.yml)
- `queue` - Laravel queue worker
- `postgres` - Database (port from projects.yml)
- `redis` - Cache/session (port from projects.yml)
- `minio` - Object storage (api + console ports)
- `mailpit` - Mail testing (smtp + web ports)
- Optional: `meilisearch` - Search engine

**Required Files:**
- `docker-compose.yml` - Generated by bootstrap
- `docker/php/Dockerfile` - PHP container config
- `docker/php/php.ini` - PHP settings
- `docker/nginx/default.conf` - Nginx vhost
- `.env` - Laravel environment (from ~/.secrets/{project}/)
- `auth.json` - Composer auth (from ~/.secrets/{project}/)
- `vite.config.js` - With correct port and strictPort

**Caddy Entry:**
```yaml
- domain: myproject.test
  port: 80XX  # nginx port from projects.yml
  wildcard: true  # if subdomains needed
```

**Common Issues:**
1. **500 Error**: Check `storage/logs/laravel.log` for actual error
2. **"Connection refused"**: Docker services not running or wrong port
3. **Vite assets not loading**: Vite not running or wrong port in vite.config.js
4. **"Host not allowed"**: Add domain to `allowedHosts` in vite.config.js

### Python Projects (`type: python`)

**Typical Services:**
- Web framework (Django, FastAPI, Flask)
- Database (PostgreSQL, MariaDB)
- Redis (cache/celery)
- Celery workers (if async tasks)

**Required Files:**
- `docker-compose.yml` or virtual environment
- `.env` - Environment variables
- `requirements.txt` or `pyproject.toml`

**Caddy Entry:**
```yaml
- domain: myproject.test
  port: 80XX  # web server port
```

### R/Statistics Projects (`type: rstats`)

**Typical Setup:**
- R environment with renv
- Plumber API (if web interface)
- Vite dev server (if Vue/React frontend)

**Required Files:**
- `renv.lock` - R package versions
- `vite.config.js` - If has frontend (with correct port)

**Special Considerations:**
- R projects may have both R backend and JS frontend
- Example: `framework` has `gui-dev/` with Vite on port 5175
- Plumber API typically on port 8080 (internal)

### Utility Projects (`type: utility`)

**Minimal Setup:**
- Just editor + optional tmux
- No Docker services
- No web server

## Troubleshooting Guide

### Site Won't Load (Connection Refused)

1. **Check Docker containers are running:**
   ```bash
   docker ps --filter "name=projectname"
   ```

2. **Check Caddy is proxying to correct port:**
   ```bash
   cat /etc/caddy/Caddyfile | grep -A2 "myproject.test"
   curl -I http://localhost:PORT  # Test directly
   ```

3. **Check ports match across all configs:**
   - projects.yml
   - docker-compose.yml
   - Caddy dev_sites

### Site Returns 500 Error

1. **Check application logs:**
   ```bash
   # Laravel
   tail -50 ~/Projects/myproject/storage/logs/laravel.log | grep ERROR

   # Check PHP container logs
   docker logs myproject-php --tail 50
   ```

2. **Common causes:**
   - Missing database migrations
   - Missing .env file
   - Database connection issues

### Vite Assets Not Loading / Blocked Host

1. **Check Vite is running on correct port:**
   ```bash
   curl -I http://localhost:51XX  # Should return 404, not connection refused
   ```

2. **Check vite.config.js has:**
   - Correct port matching projects.yml
   - `strictPort: true`
   - `allowedHosts: ['myproject.test']` if behind Caddy

3. **Restart Vite after config changes:**
   ```bash
   # In project tmux session
   npm run dev
   ```

### DNS Not Resolving (.test domains)

1. **Check dnsmasq is running:**
   ```bash
   systemctl status dnsmasq
   ```

2. **Test DNS resolution:**
   ```bash
   dig myproject.test +short  # Should return 127.0.0.1
   ```

3. **Browser treating URL as search:**
   - Type `http://myproject.test` with protocol
   - Or add trailing slash: `myproject.test/`

### Docker Containers Won't Start

1. **Check port conflicts:**
   ```bash
   lsof -i :PORT
   ```

2. **Check container logs:**
   ```bash
   docker logs myproject-nginx
   docker logs myproject-php
   ```

3. **Rebuild if Dockerfile changed:**
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

### Windows

### Windows open on wrong workspace
- Ensure `~/.machine` file contains either "desktop" or "laptop"
- Check that window appearance loops complete (increase timeout if needed)

### Docker services timeout
- Increase `MAX_WAIT` in launch script (default: 60 seconds)
- Check health check commands in `docker-compose.yml`

### Browser/editor positioning wrong
- Desktop: Verify browser opens before editor
- Laptop: Ensure window appearance loops complete before workspace switches

## Docker Restart Policies

All containers use `restart: on-failure`:
- Restarts automatically if container crashes (non-zero exit)
- Does NOT auto-start on system boot
- Containers only start when explicitly launched via `docker compose up`

To stop containers from restarting on boot after a reboot:
```bash
docker stop $(docker ps -q)  # Stop all running containers
```

## Current Project Port Assignments

Reference for existing projects (check projects.yml for authoritative source):

| Project | Vite | Nginx | Postgres | Redis | Domain |
|---------|------|-------|----------|-------|--------|
| pequod | 5173 | 8010 | 5440 | 6390 | academic.test |
| better-shoes | 5174 | 8020 | 5441 | 6391 | better-shoes.test |
| framework | 5175 | - | - | - | framework.test |
| framework-site | 5176 | 8032 | 5442 | 6392 | site.framework.test |
| flint | 5177 | 8031 | 5435 | 6384 | flint.test |
| naaccord | - | 8040 | - | 6393 | naaccord.test |

## Project Management CLI Tools

Two CLI tools manage project setup:

### pm-new: Create New Project (Outside-In)

Creates a new project from scratch. Use when starting fresh.

```bash
pm-new
```

Interactive prompts for:
1. Project name (display name)
2. PM directory name (kebab-case)
3. Project type (utility, laravel, python, rstats)
4. Editor preference (vscode, positron, neovim)
5. Docker Compose usage
6. Default workspace
7. View URL (for web projects)
8. Link to existing directory or clone from GitHub
9. Project alias

Creates all PM scripts, updates projects.yml and aliases, optionally clones repo.

### pm-init: Initialize Existing Project (Inside-Out)

Initialize project management from an existing code directory, or augment an existing project entry. Use when you already have code and want to add PM scaffolding.

```bash
pm-init              # Interactive - asks for alias first
pm-init obsr         # Check/augment existing project by alias
pm-init ~/Projects/x # Initialize from directory
```

**Discovery Phase** - Reports what exists with ✓/✗:
```
Checking what exists for alias 'obsr'...

  ✓ projects.yml entry: observational-research-methods-in-r
  → type: rstats
  → path: ~/Projects/observational-research-methods-in-r
  ✓ PM directory: ~/Omarchy/projects/observational-research-methods-in-r
  ✓ launch script
  ✓ kill script
  ✓ bootstrap script
  ✓ tmux.sh script
  ✗ Code directory (not cloned yet)
  ✓ Shell aliases in .aliases

Actions needed:
  - Add github_repo to projects.yml
```

**Auto-detection** from code directory:
- **Type**: `artisan` → laravel, `renv.lock`/`DESCRIPTION`/`.Rproj` → rstats, `requirements.txt`/`pyproject.toml` → python
- **GitHub repo**: from git remote origin
- **Docker**: presence of `docker-compose.yml`
- **Editor**: rstats defaults to positron, others to vscode

**Augment mode** - If project exists in projects.yml:
- Only prompts for missing fields (e.g., github_repo)
- Offers to run bootstrap if code directory missing

**Create mode** - If project doesn't exist:
- Full setup flow (like pm-new but starting from code)
- Detects and suggests defaults from directory contents

### When to Use Which

| Scenario | Tool |
|----------|------|
| Starting a brand new project | `pm-new` |
| Have code, need PM scaffolding | `pm-init` (from code dir) |
| Project in projects.yml, missing github_repo | `pm-init alias` |
| Check what's configured for a project | `pm-init alias` |
| Clone existing repo to new machine | `pm-init alias` then bootstrap |

## See Also

- `/home/erik/Omarchy/ansible/roles/projects/` - Ansible role that generates projects
- `/home/erik/Omarchy/config/projects/projects.yml` - Project configuration
- `/home/erik/Omarchy/ansible/roles/caddy/defaults/main.yml` - Caddy reverse proxy sites
- `/home/erik/Omarchy/docs/manual/14-development-environments.md` - Development environment docs
