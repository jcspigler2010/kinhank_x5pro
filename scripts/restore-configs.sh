#!/bin/sh
# Restore configs from a backup to the X5 Pro.
# Usage: sh restore-configs.sh [backup_dir]
#
# If no backup_dir is specified, uses the most recent backup.

BACKUP_BASE="../backups"

if [ -n "$1" ]; then
    BACKUP_DIR="$1"
else
    BACKUP_DIR=$(ls -td "$BACKUP_BASE"/*/ 2>/dev/null | head -1)
fi

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: No backup found."
    echo "Usage: sh restore-configs.sh [backup_directory]"
    echo "Available backups:"
    ls -d "$BACKUP_BASE"/*/ 2>/dev/null || echo "  (none)"
    exit 1
fi

echo "============================================"
echo "  Restoring from: $BACKUP_DIR"
echo "============================================"
echo ""
echo "WARNING: This will overwrite current configs on the device."
echo "Press Enter to continue or Ctrl+C to cancel..."
read _

# Helper
push_if_exists() {
    SRC="$1"
    DEST="$2"
    if [ -f "$SRC" ]; then
        adb push "$SRC" "$DEST" 2>/dev/null && echo "  OK: $DEST" || echo "  FAIL: $DEST"
    fi
}

echo "--- RetroArch ---"
push_if_exists "$BACKUP_DIR/retroarch/retroarch.cfg" "/storage/emulated/0/RetroArch/retroarch.cfg"
if [ -d "$BACKUP_DIR/retroarch/autoconfig/android" ]; then
    for f in "$BACKUP_DIR/retroarch/autoconfig/android/"*.cfg; do
        [ -f "$f" ] && adb push "$f" "/storage/emulated/0/RetroArch/autoconfig/android/" 2>/dev/null
    done
    echo "  OK: RetroArch autoconfig profiles"
fi

echo ""
echo "--- Dolphin ---"
if [ -d "$BACKUP_DIR/dolphin/Config" ]; then
    DOLPHIN_DIR=$(adb shell "find /storage/emulated/0/Android/data/org.dolphinemu.dolphinemu/ -type d -name Config 2>/dev/null" | head -1 | tr -d '\r')
    [ -n "$DOLPHIN_DIR" ] && adb push "$BACKUP_DIR/dolphin/Config/." "$DOLPHIN_DIR/" 2>/dev/null && echo "  OK: Dolphin config"
fi

echo ""
echo "--- AetherSX2 ---"
for pkg in xyz.aethersx2.android xyz.aethersx2.android.nethersx2; do
    push_if_exists "$BACKUP_DIR/aethersx2/$pkg/PCSX2.ini" "/storage/emulated/0/Android/data/$pkg/files/inis/PCSX2.ini"
done

echo ""
echo "--- DuckStation ---"
push_if_exists "$BACKUP_DIR/duckstation/settings.ini" "/storage/emulated/0/Android/data/com.github.stenzek.duckstation/files/settings.ini"

echo ""
echo "--- Flycast ---"
push_if_exists "$BACKUP_DIR/flycast/emu.cfg" "/storage/emulated/0/Android/data/com.flycast.emulator/files/data/emu.cfg"
if [ -d "$BACKUP_DIR/flycast/mappings" ]; then
    for f in "$BACKUP_DIR/flycast/mappings/"*.cfg; do
        [ -f "$f" ] && adb push "$f" "/storage/emulated/0/Android/data/com.flycast.emulator/files/data/mappings/" 2>/dev/null
    done
    echo "  OK: Flycast mappings"
fi

echo ""
echo "--- Redream ---"
push_if_exists "$BACKUP_DIR/redream/redream.cfg" "/storage/emulated/0/Android/data/io.recompiled.redream/files/redream.cfg"

echo ""
echo "--- PPSSPP ---"
if [ -f "$BACKUP_DIR/ppsspp/controls.ini" ]; then
    PPSSPP_DIR=$(adb shell "find /storage/emulated/0/ -type d -path '*/PSP/SYSTEM' 2>/dev/null" | head -1 | tr -d '\r')
    [ -n "$PPSSPP_DIR" ] && push_if_exists "$BACKUP_DIR/ppsspp/controls.ini" "$PPSSPP_DIR/controls.ini"
fi

echo ""
echo "--- Citra ---"
if [ -f "$BACKUP_DIR/citra/sdl2-config.ini" ]; then
    for dir in /storage/emulated/0/citra-emu /storage/emulated/0/Android/data/org.citra.emu/files/citra-emu; do
        if adb shell "[ -d '$dir/config' ]" 2>/dev/null; then
            push_if_exists "$BACKUP_DIR/citra/sdl2-config.ini" "$dir/config/sdl2-config.ini"
            break
        fi
    done
fi

echo ""
echo "--- Yaba Sanshiro ---"
for pkg in org.devmiyax.yabasanshioro2 org.devmiyax.yabasanshioro2.pro; do
    YABA_DIR="/storage/emulated/0/Android/data/$pkg/files/yabause"
    push_if_exists "$BACKUP_DIR/yabasanshiro/$pkg/keymap_v2.json" "$YABA_DIR/keymap_v2.json"
    push_if_exists "$BACKUP_DIR/yabasanshiro/$pkg/keymap_player2_v2.json" "$YABA_DIR/keymap_player2_v2.json"
done

echo ""
echo "============================================"
echo "  Restore complete."
echo "  Force-stop and relaunch emulators for changes to take effect."
echo "============================================"
