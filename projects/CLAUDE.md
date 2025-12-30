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

## Troubleshooting

### Windows open on wrong workspace
- Ensure `~/.machine` file contains either "desktop" or "laptop"
- Check that window appearance loops complete (increase timeout if needed)

### Docker services timeout
- Increase `MAX_WAIT` in launch script (default: 60 seconds)
- Check health check commands in `docker-compose.yml`

### Browser/editor positioning wrong
- Desktop: Verify browser opens before editor
- Laptop: Ensure window appearance loops complete before workspace switches

## See Also

- `/home/erik/Omarchy/ansible/roles/projects/` - Ansible role that generates projects
- `/home/erik/Omarchy/config/projects/projects.yml` - Project configuration
- `/home/erik/Omarchy/docs/manual/14-development-environments.md` - Development environment docs
