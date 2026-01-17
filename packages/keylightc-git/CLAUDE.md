# keylightc-git (patched)

Custom build of keylightc with keyd virtual keyboard support.

## Why patched?

The upstream keylightc has hardcoded input device names and only listens to:
- `AT Translated Set 2 keyboard` (physical keyboard)
- `PIXA3854:00 093A:0274 Touchpad`

When using keyd for keyboard remapping, keyd grabs the physical keyboard and re-emits through its virtual keyboard. The patch adds `keyd virtual keyboard` to the device list so keylightc responds to keyboard input when keyd is active.

## Files

- `PKGBUILD` - Arch package build script
- `keyd-support.patch` - Adds keyd virtual keyboard to device list

## Building

```bash
cd packages/keylightc-git
makepkg -si --noconfirm
```

Or via ansible:
```bash
ANSIBLE_CONFIG=~/Omarchy/ansible/ansible.cfg ansible-playbook ~/Omarchy/ansible/playbook.yml -l laptop --tags framework
```
