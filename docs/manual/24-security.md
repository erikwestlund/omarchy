# Security

Omarchy implements comprehensive security measures designed for real-world use cases where data protection is critical.

## Core Security Features

### Full-Disk Encryption (Mandatory)

Full-disk encryption is mandatory using LUKS (Linux Unified Key Setup). This protects data if devices are lost or stolen.

### Firewall Configuration

The system enables firewall protections by default, restricting incoming traffic except for:
- SSH (port 22)
- LocalSend (port 53317)

The implementation uses "ufw-docker" to prevent accidental container exposure to external networks.

### Software Updates

Omarchy relies on Arch Linux, a rolling-release distribution, ensuring users access the latest security patches immediately via `yay -Syu`.

### Package Management

The system defaults to packages from:
- Arch's core/extra/multilib repositories
- Omarchy's own package repository

While AUR access is available, it's not enabled by default.

### Infrastructure Protection

Cloudflare's DDoS protection and CDN infrastructure protect distribution channels including ISOs, packages, and mirrors.

## Signing Keys

GPG public key for verification:
```
40DFB630FF42BCFFB047046CF0134EE680CAC571
```
(searchable on openpgp.org)

ISO signatures are available by appending `.sig` to release URLs.

The `omarchy/omarchy-keyring` package manages key updates.
