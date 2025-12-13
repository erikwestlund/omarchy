# The Shell

Omarchy includes enhanced shell tools beyond standard Linux utilities.

## fzf - Fuzzy Finder

fzf gives you fuzzy finding of files via the `ff` alias. Users can navigate directories and preview files while narrowing results.

- Integrates with command history via `Ctrl+R`
- Integrates with Neovim (`Space Space`)
- Documentation: `man fzf`

## Zoxide - Smart cd

Zoxide is a replacement for cd. It remembers the directories you've been in, so you can more easily jump to them next time.

After visiting `~/.local/share/omarchy` once, users can return via abbreviated commands like `cd omarchy` or `cd oma`.

Documentation: `man zoxide`

## ripgrep - Fast Search

ripgrep searches the contents of files by using `rg <pattern> <path>`.

Example: `rg Controller app/` finds all mentions of Controller in the app directory.

- Integrates with Neovim via `Space S G`
- Documentation: `man rg`

## eza - Better ls

eza is a replacement for ls. It gives you directory listings with more information, color, and icons.

Aliases:
- `ls` - default listing
- `lt` - two-level nesting
- `lsa` - with hidden files
- `lta` - nested with hidden files

Documentation: `man eza`

## fd - Better find

fd is an easier to use replacement for `find`.

Examples:
- `fd person.rb` - search current tree
- `fd person.rb /` - search filesystem
- `fd person.rb / -H` - filesystem including hidden directories

Documentation: `man fd`

## try - Experiment Manager

try makes it easy to manage programming experiments with date-stamped directories.

Experiments stored in `~/Work/tries`, accessed via the `try` command.
