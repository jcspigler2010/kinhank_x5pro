#!/bin/sh
# Run this via: adb shell < diagnose-controllers.sh
# Or: adb push diagnose-controllers.sh /data/local/tmp/ && adb shell sh /data/local/tmp/diagnose-controllers.sh
#
# Captures all controller info needed to finalize config templates.

echo "===== CONNECTED INPUT DEVICES ====="
dumpsys input | grep -A 5 "Input Device"

echo ""
echo "===== DEVICE NAMES AND IDS ====="
cat /proc/bus/input/devices 2>/dev/null || echo "(not available - try getevent -pl)"

echo ""
echo "===== GETEVENT DEVICE LIST ====="
getevent -pl 2>/dev/null | head -100

echo ""
echo "===== BLUETOOTH CONNECTED DEVICES ====="
dumpsys bluetooth_manager | grep -A 3 "name:" 2>/dev/null || echo "(not available)"

echo ""
echo "===== INSTALLED EMULATOR PACKAGES ====="
pm list packages 2>/dev/null | grep -iE "retroarch|dolphin|ppsspp|mupen|aether|nether|redream|flycast|duckstation|mame|pegasus|citra|yaba|sanshiro" || echo "(none found)"

echo ""
echo "===== RETROARCH AUTOCONFIG PROFILES ====="
ls -la /storage/emulated/0/RetroArch/autoconfig/android/ 2>/dev/null || echo "(dir not found)"

echo ""
echo "===== RETROARCH MAIN CONFIG (input section) ====="
grep -i "input_player" /storage/emulated/0/RetroArch/retroarch.cfg 2>/dev/null | head -40 || echo "(not found)"

echo ""
echo "===== DOLPHIN CONFIG ====="
find /storage/emulated/0/Android/data/org.dolphinemu.dolphinemu/ -name "GCPadNew.ini" 2>/dev/null | while read f; do
    echo "--- $f ---"
    cat "$f"
done
echo "(end dolphin)"

echo ""
echo "===== PPSSPP CONTROLS ====="
find /storage/emulated/0/ -path "*/PSP/SYSTEM/controls.ini" 2>/dev/null | while read f; do
    echo "--- $f ---"
    cat "$f"
done
echo "(end ppsspp)"

echo ""
echo "===== AETHERSX2 / NETHERSX2 CONFIG ====="
for pkg in xyz.aethersx2.android xyz.aethersx2.android.nethersx2; do
    INI="/storage/emulated/0/Android/data/$pkg/files/inis/PCSX2.ini"
    if [ -f "$INI" ]; then
        echo "--- $INI ---"
        grep -A 30 "^\[Pad1\]" "$INI" 2>/dev/null
        echo "..."
        grep -A 30 "^\[Pad2\]" "$INI" 2>/dev/null
    fi
done
echo "(end aethersx2)"

echo ""
echo "===== DUCKSTATION CONFIG ====="
DUCK_INI="/storage/emulated/0/Android/data/com.github.stenzek.duckstation/files/settings.ini"
if [ -f "$DUCK_INI" ]; then
    echo "--- $DUCK_INI ---"
    grep -A 30 "^\[Pad1\]" "$DUCK_INI" 2>/dev/null
    echo "..."
    grep -A 30 "^\[Pad2\]" "$DUCK_INI" 2>/dev/null
else
    echo "(not found)"
fi
echo "(end duckstation)"

echo ""
echo "===== FLYCAST CONFIG ====="
FLYCAST_DIR="/storage/emulated/0/Android/data/com.flycast.emulator/files/data"
if [ -d "$FLYCAST_DIR/mappings" ]; then
    echo "--- existing mappings ---"
    ls -la "$FLYCAST_DIR/mappings/"
    for f in "$FLYCAST_DIR/mappings/"*.cfg; do
        echo "--- $f ---"
        cat "$f"
    done
else
    echo "(mappings dir not found)"
fi
# Also grab emu.cfg input section
if [ -f "$FLYCAST_DIR/emu.cfg" ]; then
    echo "--- emu.cfg [input] ---"
    grep -A 20 "^\[input\]" "$FLYCAST_DIR/emu.cfg" 2>/dev/null
fi
echo "(end flycast)"

echo ""
echo "===== REDREAM CONFIG ====="
REDREAM_CFG="/storage/emulated/0/Android/data/io.recompiled.redream/files/redream.cfg"
if [ -f "$REDREAM_CFG" ]; then
    echo "--- $REDREAM_CFG ---"
    grep -E "^(input|profile)" "$REDREAM_CFG"
else
    echo "(not found)"
fi
echo "(end redream)"

echo ""
echo "===== CITRA CONFIG ====="
for dir in /storage/emulated/0/citra-emu /storage/emulated/0/Android/data/org.citra.emu/files/citra-emu /storage/emulated/0/Android/data/org.citra.citra_emu/files/citra-emu; do
    CFG="$dir/config/sdl2-config.ini"
    if [ -f "$CFG" ]; then
        echo "--- $CFG ---"
        grep -A 30 "^\[Controls\]" "$CFG" 2>/dev/null
    fi
done
echo "(end citra)"

echo ""
echo "===== YABA SANSHIRO CONFIG ====="
for pkg in org.devmiyax.yabasanshioro2 org.devmiyax.yabasanshioro2.pro; do
    KM="/storage/emulated/0/Android/data/$pkg/files/yabause/keymap_v2.json"
    if [ -f "$KM" ]; then
        echo "--- $KM ---"
        cat "$KM"
    fi
    KM2="/storage/emulated/0/Android/data/$pkg/files/yabause/keymap_player2_v2.json"
    if [ -f "$KM2" ]; then
        echo "--- $KM2 ---"
        cat "$KM2"
    fi
done
echo "(end yabasanshiro)"

echo ""
echo "===== DONE ====="
echo "Next step: connect all controllers, then run:"
echo "  getevent -l"
echo "Press buttons on each controller to see keycodes. Ctrl+C to stop."
