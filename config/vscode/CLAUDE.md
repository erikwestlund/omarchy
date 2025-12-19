# VS Code Configuration

Shared VS Code settings and keybindings.

## IMPORTANT: Sync with Positron

VS Code and Positron share the same keybindings and settings. When making changes:

1. Edit files in `config/vscode/`
2. Copy to `config/positron/` for any files that don't conflict:
   - `keybindings.json` - copy directly
   - `settings.json` - may have Positron-specific settings, merge carefully
   - `snippets/` - copy directly

The ansible vscode role symlinks these to `~/.config/Code/User/` and `~/.config/Positron/User/`.

## keyd Integration (IMPORTANT)

VS Code has issues with the Super (Meta) key on Linux. To work around this, we use `keyd-application-mapper` to convert Super key combos to Ctrl in VS Code/Positron.

### How it works

1. `keyd-application-mapper` runs as a daemon
2. It reads `~/.config/keyd/app.conf` which has `[code]` and `[positron]` sections
3. When VS Code is focused, it intercepts keypresses and converts:
   - Super+P → Ctrl+P (file browser)
   - Super+S → Ctrl+S (save)
   - Super+Alt+E → Ctrl+Alt+E (file explorer)
   - etc.

### Keybinding implications

Because of this transformation, keybindings in `keybindings.json` must use `ctrl+` instead of `meta+`:

```json
// CORRECT - matches what keyd sends to VS Code
{ "key": "ctrl+alt+e", "command": "workbench.view.explorer" }

// WRONG - VS Code never sees meta because keyd converts it
{ "key": "meta+alt+e", "command": "workbench.view.explorer" }
```

### Avoid HJKL Keys

Never use H, J, K, or L in Super+Alt keybindings. These conflict with Hyprland's vim-style navigation hotkeys and produce garbled key combinations.

### Debugging

If keybindings aren't working:
1. Check `keyd-application-mapper` is running: `pgrep -f keyd-application-mapper`
2. Use VS Code's "Record Keys" in Keyboard Shortcuts to see what VS Code receives
3. If it shows weird chords like "ctrl+alt+e ctrl+alt+meta", keyd may be misconfigured

The app.conf is deployed by the keyd ansible role from `ansible/roles/keyd/templates/app.conf.j2`.
