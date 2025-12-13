# Fingerprint & FIDO2 Authentication

## Fingerprint Authentication

Omarchy supports fingerprint authentication on compatible devices like the Framework 13 laptop.

### Setup

1. Access the Omarchy menu using `Super + Alt + Space`
2. Navigate to _Setup > Security > Fingerprint_
3. The system will install necessary packages, collect your fingerprint, and verify it

### What It Works For

- Unlocking the lock screen (triggered with `Super + Escape`)
- Entering sudo mode
- Authorizing system prompts

### Workaround for External Keyboards

If you need to use a keyboard without a fingerprint sensor, press `CTRL + C` when prompted for your fingerprint during sudo authentication.

### Removal

Access _Remove > Fingerprint_ in the Omarchy menu, or use the Setup menu in the Omarchy TUI.

## FIDO2 Authentication

For users with FIDO2 security devices:

### Setup

1. Open the Omarchy menu (`Super + Alt + Space`)
2. Select _Setup > Security > Fido2_
3. Configure the device for sudo authentication

### Limitations

FIDO2 authentication in Omarchy is restricted to sudo operations only—it cannot be used for unlocking the computer.

### Removal

Navigate to _Remove > Fido2_ in the Omarchy menu to disable this authentication method.
