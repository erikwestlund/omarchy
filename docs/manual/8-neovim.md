# Neovim

Neovim is a modern implementation of the vi editor created by Bill Joy all the way back in 1976. It's a modal editor with separate insert and command modes. It has a steep learning curve but significant payoff once mastered.

## Learning Resources

- ThePrimeagen's YouTube series on vim fundamentals
- Typecraft's course on configuring Neovim from scratch

## LazyVim Distribution

Omarchy includes LazyVim, a distribution of Neovim plugins and configurations that comes pre-tuned without requiring manual setup. The Space key serves as the leader key for command access.

## Essential Keybindings

| Action | Shortcut |
|--------|----------|
| Fuzzy file search | `Space Space` |
| Grep search with preview | `Space S G` |
| Toggle file tree | `Space E` |
| Switch between file tree and editor | `Ctrl + W W` |
| Navigate between tabs | `Shift + H/L` |
| Close current tab | `Space B D` |
| Launch LazyGit | `Space G G` |

## File Tree Operations

Within the file tree:
- Create files: `a`
- Create directories: `A`
- Display all commands: `?`

## Starting Neovim

- Launch via `Super + Shift + N`
- Or in terminal with `n` (alias for `nvim`)

## Privileged File Editing

For editing system files, use:
```
sudoedit /etc/sudoers.d/[filename]
```
