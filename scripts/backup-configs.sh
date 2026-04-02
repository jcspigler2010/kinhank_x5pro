#!/bin/sh
# Backup ALL emulator configs from the X5 Pro before making any changes.
# Run from your Mac: sh backup-configs.sh
#
# This should be the FIRST thing you run after connecting via ADB.
# Creates a timestamped backup directory with everything we might touch.

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="../backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "============================================"
echo "  Kinhank X5 Pro Config Backup"
echo "  Saving to: $BACKUP_DIR"
echo "============================================"
echo ""

# Helper: pull a file/dir, skip if not found
pull_if_exists() {
    SRC="$1"
    DEST="$2"
    mkdir -p "$(dirname "$DEST")"
    if adb shell "[ -e '$SRC' ]" 2>/dev/null; then
        adb pull "$SRC" "$DEST" 2>/dev/null && echo "  OK: $SRC" || echo "  FAIL: $SRC (permission denied?)"
    else
        echo "  SKIP: $SRC (not found)"
    fi
}

# Helper: pull a directory recursively
pull_dir_if_exists() {
    SRC="$1"
    DEST="$2"
    mkdir -p "$DEST"
    if adb shell "[ -d '$SRC' ]" 2>/dev/null; then
        adb pull "$SRC/." "$DEST" 2>/dev/null && echo "  OK: $SRC/" || echo "  FAIL: $SRC/ (permission denied?)"
    else
        echo "  SKIP: $SRC/ (not found)"
    fi
}

echo "--- RetroArch ---"
pull_if_exists "/storage/emulated/0/RetroArch/retroarch.cfg" "$BACKUP_DIR/retroarch/retroarch.cfg"
pull_dir_if_exists "/storage/emulated/0/RetroArch/autoconfig/android" "$BACKUP_DIR/retroarch/autoconfig/android"
pull_dir_if_exists "/storage/emulated/0/RetroArch/config" "$BACKUP_DIR/retroarch/config"

echo ""
echo "--- Dolphin (GameCube/Wii) ---"
pull_dir_if_exists "/storage/emulated/0/Android/data/org.dolphinemu.dolphinemu/files/Config" "$BACKUP_DIR/dolphin/Config"

echo ""
echo "--- PPSSPP (PSP) ---"
PPSSPP_DIR=$(adb shell "find /storage/emulated/0/ -type d -path '*/PSP/SYSTEM' 2>/dev/null" | head -1 | tr -d '\r')
if [ -n "$PPSSPP_DIR" ]; then
    pull_if_exists "$PPSSPP_DIR/controls.ini" "$BACKUP_DIR/ppsspp/controls.ini"
    pull_if_exists "$PPSSPP_DIR/ppsspp.ini" "$BACKUP_DIR/ppsspp/ppsspp.ini"
else
    echo "  SKIP: PPSSPP directory not found"
fi

echo ""
echo "--- Mupen64Plus (N64) ---"
for pkg in org.mupen64plusae.v3.fzurita com.retroarch; do
    M64_CFG=$(adb shell "find /storage/emulated/0/Android/data/$pkg/ -name 'mupen64plus.cfg' 2>/dev/null" | head -1 | tr -d '\r')
    if [ -n "$M64_CFG" ]; then
        pull_if_exists "$M64_CFG" "$BACKUP_DIR/mupen64plus/mupen64plus.cfg"
        break
    fi
done
echo "  (also checked via RetroArch core)"

echo ""
echo "--- AetherSX2 / NetherSX2 (PS2) ---"
for pkg in xyz.aethersx2.android xyz.aethersx2.android.nethersx2; do
    AETH_DIR="/storage/emulated/0/Android/data/$pkg/files/inis"
    pull_if_exists "$AETH_DIR/PCSX2.ini" "$BACKUP_DIR/aethersx2/$pkg/PCSX2.ini"
done

echo ""
echo "--- DuckStation (PS1) ---"
pull_if_exists "/storage/emulated/0/Android/data/com.github.stenzek.duckstation/files/settings.ini" "$BACKUP_DIR/duckstation/settings.ini"

echo ""
echo "--- Flycast (Dreamcast) ---"
FLYCAST_DATA="/storage/emulated/0/Android/data/com.flycast.emulator/files/data"
pull_if_exists "$FLYCAST_DATA/emu.cfg" "$BACKUP_DIR/flycast/emu.cfg"
pull_dir_if_exists "$FLYCAST_DATA/mappings" "$BACKUP_DIR/flycast/mappings"

echo ""
echo "--- Redream (Dreamcast) ---"
pull_if_exists "/storage/emulated/0/Android/data/io.recompiled.redream/files/redream.cfg" "$BACKUP_DIR/redream/redream.cfg"

echo ""
echo "--- Citra (3DS) ---"
for dir in /storage/emulated/0/citra-emu /storage/emulated/0/Android/data/org.citra.emu/files/citra-emu /storage/emulated/0/Android/data/org.citra.citra_emu/files/citra-emu; do
    pull_if_exists "$dir/config/sdl2-config.ini" "$BACKUP_DIR/citra/sdl2-config.ini"
done

echo ""
echo "--- Yaba Sanshiro 2 (Saturn) ---"
for pkg in org.devmiyax.yabasanshioro2 org.devmiyax.yabasanshioro2.pro; do
    YABA_DIR="/storage/emulated/0/Android/data/$pkg/files/yabause"
    pull_if_exists "$YABA_DIR/keymap_v2.json" "$BACKUP_DIR/yabasanshiro/$pkg/keymap_v2.json"
    pull_if_exists "$YABA_DIR/keymap_player2_v2.json" "$BACKUP_DIR/yabasanshiro/$pkg/keymap_player2_v2.json"
done

echo ""
echo "--- Pegasus Frontend ---"
pull_dir_if_exists "/storage/emulated/0/Android/data/org.pegasus_frontend.android/files" "$BACKUP_DIR/pegasus"

echo ""
echo "--- System info ---"
adb shell getprop ro.build.version.release > "$BACKUP_DIR/android_version.txt" 2>/dev/null
adb shell getprop ro.product.model >> "$BACKUP_DIR/android_version.txt" 2>/dev/null
adb shell pm list packages > "$BACKUP_DIR/installed_packages.txt" 2>/dev/null

echo ""
echo "============================================"
echo "  Backup complete: $BACKUP_DIR"
echo "  $(find "$BACKUP_DIR" -type f | wc -l | tr -d ' ') files saved"
echo "============================================"
echo ""
echo "To restore any file:"
echo "  adb push $BACKUP_DIR/<path> <original_device_path>"
