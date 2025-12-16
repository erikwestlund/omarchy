# keyd Role

Configures keyd for keyboard remapping.

## Keyboard Configuration

Each machine defines a `keyboards` list in its host_vars specifying which keyboard configs to deploy:

```yaml
keyboards:
  - framework    # Framework laptop internal keyboard
  - logitech     # Logitech USB receiver
```

## Template Naming Convention

Logitech keyboards use machine-specific templates because different machines may have different receivers/keyboards with different layouts:

- `logitech-{{ inventory_hostname }}.conf.j2` - Machine-specific Logitech config

For example:
- `logitech-desktop.conf.j2` - Desktop's Logitech Bolt receiver (no alt/super swap)
- `logitech-laptop.conf.j2` - Laptop's external Logitech keyboard (with alt/super swap)

The Framework keyboard uses a shared template since it's consistent across Framework laptops:
- `framework.conf.j2` - Framework laptop internal keyboard

## Adding a New Machine

1. Add the machine to inventory.yml
2. Create `host_vars/{{ machine_name }}.yml` with `keyboards` list
3. If using Logitech, create `templates/logitech-{{ machine_name }}.conf.j2`
