# Home Dotfiles

Dotfiles symlinked to `~/` via ansible dotfiles role.

## .aliases

Shell aliases and functions. Symlinked to `~/.aliases`.

### Laravel/PHP Docker Wrappers

Convention-based auto-detection for `php`, `art`, and `composer` commands.

**How it works:**
- When in `~/Projects/{name}/`, checks if `{name}-php` container is running
- If container exists: runs command inside the container via `docker exec`
- If no container: falls back to local command

**Convention:**
- Project directory: `~/Projects/my-app/`
- Container name: `my-app-php`

**Commands:**
- `php` - Runs PHP (in container or local)
- `art` - Runs `php artisan` (Laravel)
- `composer` - Runs Composer

**Example:**
```bash
cd ~/Projects/better-shoes
php -v          # runs: docker exec -it better-shoes-php php -v
art migrate     # runs: docker exec -it better-shoes-php php artisan migrate
composer install # runs: docker exec -it better-shoes-php composer install

cd ~/some-other-dir
php -v          # runs local php
```

No configuration needed - just follow the naming convention.

### Printer Management

Aliases for managing the Brother MFC-L2710DW network printer.

**Commands:**
- `printer-status` - Shows printer state, default printer, and any queued jobs
- `printer-reset` - Resets the printer connection (restarts CUPS, re-adds printer)

**Setup:**
- Uses direct IPP connection to `brother-printer.local` (mDNS hostname)
- `cups-browsed` is disabled to prevent duplicate printer entries
- Printer is configured as system default

**When to use `printer-reset`:**
- Printer shows "disabled" or connection errors
- Print jobs stuck in queue
- After network changes or printer power cycle
