# Updates

## Update Process

Omarchy provides a built-in update mechanism accessible through the menu (`Super + Alt + Space`). Select "Update > Omarchy" to retrieve the latest code and apply system changes.

## What Updates Do

The update procedure performs three main functions:

1. **Pulls latest code** from Omarchy's repository
2. **Runs migrations** to synchronize the system with current versions
3. **Updates packages** from three sources:
   - Official Arch repository
   - Omarchy Package Repository
   - AUR

## Visual Indicator

When new releases are made, a circle arrow icon will appear to the right of your clock. Click it and the update process will start.

## Important Caution

**Avoid running `pacman -Syu` directly**, as this bypasses necessary configuration file updates. Skipping the official update process runs the risk that you'll miss updates to the configuration files needed to support newer versions of libraries or tools.

## Rollback Capability

The system creates snapshots before updates, allowing users to restore previous states if issues arise post-update.
