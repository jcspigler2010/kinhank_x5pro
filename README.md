# Kinhank X5 Pro Controller Configuration

ADB-based controller configuration templates and scripts for the Kinhank X5 Pro retro gaming console (Android 12, Rockchip RK3588S).

## Controllers

- **GameSir T3** (wireless, 2.4GHz) — bundled with the X5 Pro
- **GameSir Nova Lite 2** x2 (wireless, 2.4GHz dongle)

## Supported Emulators

| Emulator | System(s) | Config Format | Template |
|----------|-----------|---------------|----------|
| RetroArch | NES, SNES, Genesis, GBA, MAME, etc. | `.cfg` (autoconfig) | `templates/retroarch/` |
| Dolphin | GameCube, Wii | INI (`GCPadNew.ini`) | `templates/dolphin/` |
| PPSSPP | PSP | INI (`controls.ini`) | `templates/ppsspp/` |
| Mupen64Plus FZ | N64 | INI (`mupen64plus.cfg`) | `templates/mupen64plus/` |
| AetherSX2 / NetherSX2 | PS2 | INI (`PCSX2.ini`) | `templates/aethersx2/` |
| DuckStation | PS1 | INI (`settings.ini`) | `templates/duckstation/` |
| Flycast | Dreamcast | INI (mapping `.cfg`) | `templates/flycast/` |
| Redream | Dreamcast | Custom key-value (`redream.cfg`) | `templates/redream/` |
| Citra | 3DS | INI (`sdl2-config.ini`) | `templates/citra/` |
| Yaba Sanshiro 2 | Sega Saturn | JSON (`keymap_v2.json`) | `templates/yabasanshiro/` |

## Setup Workflow

### Prerequisites

- ADB installed on your computer (`brew install android-platform-tools` on macOS)
- USB debugging enabled on the X5 Pro (Settings > Developer Options > USB Debugging)
- X5 Pro connected via USB
- All controllers connected (T3 in Android mode, Nova Lite 2s via dongles in X-Input mode)

### Step 1: Backup existing configs

**Always do this first.** Creates a timestamped snapshot of all emulator configs on the device.

```sh
cd scripts/
sh backup-configs.sh
```

Backups are saved to `backups/<timestamp>/` and excluded from git.

### Step 2: Diagnose controllers

Dumps all connected input devices, installed emulator packages, and existing controller configs.

```sh
adb push diagnose-controllers.sh /data/local/tmp/
adb shell sh /data/local/tmp/diagnose-controllers.sh
```

Save this output — it contains the actual device names, vendor/product IDs, and button codes needed to finalize the templates.

### Step 3: Capture button codes

With all controllers connected, run:

```sh
adb shell getevent -l
```

Press each button on each controller to see the keycodes it reports. Ctrl+C to stop. Use this to verify/correct the button mappings in the templates.

### Step 4: Update templates

Edit the template files with the real values from steps 2 and 3:

- Device names (e.g., `GameSir-T3 2.4G Gamepad` — confirm exact string)
- Vendor/product IDs
- Button/axis codes
- SDL device indices (which controller is `SDL-0`, `SDL-1`, etc.)

Templates marked `.partial` contain only the controller sections and must be **merged** into the emulator's existing config file — don't replace the whole file.

### Step 5: Deploy configs

```sh
cd scripts/
sh deploy-configs.sh
```

Then force-stop and relaunch each emulator:

```sh
adb shell am force-stop com.retroarch
adb shell am force-stop org.dolphinemu.dolphinemu
# etc.
```

### Emergency Rollback

Restore everything from the most recent backup:

```sh
cd scripts/
sh restore-configs.sh
```

Or specify a backup directory:

```sh
sh restore-configs.sh ../backups/20260402_143000
```

## File Structure

```
kinhank_x5pro/
├── templates/              # Controller config templates per emulator
│   ├── retroarch/          # Full autoconfig .cfg files (drop-in ready)
│   ├── dolphin/            # Full GCPadNew.ini (4 players)
│   ├── ppsspp/             # Full controls.ini
│   ├── mupen64plus/        # Full 4-player input config
│   ├── aethersx2/          # Partial — merge [Pad] sections into PCSX2.ini
│   ├── duckstation/        # Partial — merge [Pad] sections into settings.ini
│   ├── flycast/            # Full mapping files (per controller)
│   ├── redream/            # Partial — merge input/profile lines into redream.cfg
│   ├── citra/              # Partial — merge [Controls] into sdl2-config.ini
│   └── yabasanshiro/       # Full JSON keymap files (drop-in ready)
├── scripts/
│   ├── backup-configs.sh   # Step 1: Backup everything
│   ├── diagnose-controllers.sh  # Step 2: Dump device info
│   ├── deploy-configs.sh   # Step 5: Push configs to device
│   └── restore-configs.sh  # Emergency rollback
└── backups/                # Timestamped backups (gitignored)
```

## Controller Notes

### GameSir T3
- Must be in **Android mode**: hold A + press Power for 5 seconds (lights turn blue/purple)
- Works out of the box with RetroArch and MAME
- Dreamcast and PS2 emulators need manual remapping
- Reset via pinhole on the back if misbehaving

### GameSir Nova Lite 2
- Use the **2.4GHz dongle** in **X-Input mode**
- Press **A + HOME** to start
- May not have a RetroArch autoconfig profile — templates provide one

### Multi-Controller
- Android assigns controllers in detection order, which can change on reconnect
- Each emulator has its own player-to-controller assignment
- The diagnostic script captures device indices to help map controllers to player slots
