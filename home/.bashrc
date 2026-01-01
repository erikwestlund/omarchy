# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
[ -f ~/.config/secrets/config ] && { source ~/.config/secrets/config; export GITHUB_USERNAME GITHUB_PAT; }
export PATH="$HOME/.bin:$PATH"
export LIBVIRT_DEFAULT_URI="qemu:///system"
