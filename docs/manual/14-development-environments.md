# Development Environments

## Editor

Omarchy includes Neovim with LazyVim distro as the default editor. This terminal-based editor is built on the proud legacy of Vi and offers theme switcher integration.

### Alternative Editors

Available through the Omarchy Menu (`Super + Alt + Space`) under Install > Editor:
- VSCode
- Cursor
- Zed
- Sublime Text
- Helix

Additional options in Install > Package (Arch packages) or Install > AUR.

### Setting Default Editor

Access Setup > Defaults to modify the UWSM defaults file. Changes require relaunching Hyprland (`Super + Esc`).

## Terminal

Ghostty serves as the default terminal.

Alternatives with full support:
- Alacritty
- Kitty

Switch terminals via Install > Terminal (requires system restart).

## Development Environments

The Install > Development section provides setup for multiple programming environments:

- **Ruby on Rails**
- **JavaScript runtimes**: Node.js, bun, Deno
- **PHP frameworks**: Laravel, Symfony
- **Additional**: .NET, OCaml, Zig, Elixir

## Mise Version Manager

Most environments use Mise for version management.

Examples:
```bash
mise use -g ruby@3.3    # Install Ruby 3.3 globally
mise i                   # Install versions from project root
```

## Docker

Docker installation includes Docker Compose and user group configurations enabling non-root operation.

- Lazydocker: `Super + Shift + D`
- Database setup: Install > Development > Docker DB

## GitHub CLI

Authentication:
```bash
gh auth login
```

Clone private repos:
```bash
gh repo clone org/repo
```
