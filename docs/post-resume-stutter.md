# Post-Resume Stutter/Lag on Framework Ryzen AI Laptop

## Problem

After suspend/resume, the system sometimes stutters with noticeable input lag:
- btop may show low CPU utilization but elevated load average
- Mouse movement and keypresses feel sluggish
- The issue often "self-resolves" after some time or activity, but unreliably

## Potential Root Causes

There are **two known issues** that can cause this on AMD Ryzen laptops with integrated graphics:

### 1. AMD GPU DMCUB Bug (Radeon 680M/880M/890M)

**Symptoms:** Screen updates become slow, input lag, but system otherwise responsive.

**Cause:** DMCUB (Display Microcontroller Unit) firmware bug in amdgpu driver. Usually occurs after suspend/resume cycles, sometimes associated with video playback.

**Related issues:**
- https://gitlab.freedesktop.org/drm/amd/-/issues/3647
- https://community.frame.work/t/fedora-kde-becomes-suddenly-slow/58459

**Runtime fix:**
```bash
fix-resume-gpu
# or manually:
sudo cat /sys/kernel/debug/dri/1/amdgpu_gpu_recover
```

**Permanent fix:** Add to kernel cmdline:
```
amdgpu.dcdebugmask=0x10
```

### 2. AMD P-State EPP Bug

**Symptoms:** System feels slow, high load average despite low CPU usage, cores stuck at low frequencies.

**Cause:** amd-pstate-epp occasionally resumes in a broken/overly aggressive EPP state, leaving cores stuck in deep idle or slow frequency ramp.

**Runtime fix:**
```bash
fix-resume-cpu
# or manually (if using power-profiles-daemon):
powerprofilesctl set performance && sleep 1 && powerprofilesctl set balanced
# or manually (without power-profiles-daemon):
echo balance_performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
```

**Permanent fix:** Add to kernel cmdline (switches from EPP to active mode):
```
amd_pstate=active
```

## Diagnostic Scripts

Three scripts are available in `~/.bin/`:

| Script | Purpose |
|--------|---------|
| `fix-resume-status` | Show current system state for diagnosis |
| `fix-resume-gpu` | Try GPU recovery fix |
| `fix-resume-cpu` | Try CPU frequency reset |

### Workflow When Issue Occurs

1. Run `fix-resume-status` to capture diagnostic info
2. Try `fix-resume-gpu` first - if it fixes the issue, the cause is GPU-related
3. If not, try `fix-resume-cpu` - if it fixes the issue, the cause is CPU pstate-related
4. Note which fix worked for applying the permanent solution

## Applying Permanent Fix

Once you've identified which fix works, apply the permanent kernel cmdline change.

### For Limine Bootloader (Omarchy)

Create/edit `/etc/default/limine`:

```bash
# For GPU fix:
KERNEL_CMDLINE[default]+=" amdgpu.dcdebugmask=0x10"

# For CPU pstate fix:
KERNEL_CMDLINE[default]+=" amd_pstate=active"

# Or both if needed:
KERNEL_CMDLINE[default]+=" amdgpu.dcdebugmask=0x10 amd_pstate=active"
```

Then regenerate boot entries:
```bash
sudo limine-update
```

Reboot to apply.

### Verification

After reboot, verify the fix is applied:

```bash
# Check kernel cmdline
cat /proc/cmdline | grep -E "(amdgpu.dcdebugmask|amd_pstate)"

# For CPU pstate fix, verify driver changed from epp to active:
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
# Should show: amd-pstate (not amd-pstate-epp)
```

## Reverting

### Remove Runtime Fix

Runtime fixes are temporary and cleared on reboot. No action needed.

### Remove Permanent Fix

1. Edit `/etc/default/limine` and remove the added parameters
2. Run `sudo limine-update`
3. Reboot

To verify reversion:
```bash
cat /proc/cmdline  # Should not contain the removed parameters
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver  # Should show amd-pstate-epp again
```

## Why It "Self-Resolves"

Both issues can appear to self-resolve:

- **GPU bug:** Heavy GPU activity may trigger internal recovery
- **CPU pstate bug:** Sustained CPU load may force cores out of broken idle states

This doesn't mean the bug is fixed - it will likely recur on the next suspend/resume cycle.
