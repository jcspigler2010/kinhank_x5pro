#!/bin/sh
# Deploy finalized controller configs to the X5 Pro via ADB
# Run from your Mac: sh deploy-configs.sh
#
# IMPORTANT: Only run this AFTER you've finalized the templates
# with actual button codes from diagnose-controllers.sh output.

set -e

TEMPLATES="../templates"

echo "Deploying controller configs to Kinhank X5 Pro..."

# RetroArch autoconfig profiles
echo ""
echo "--- RetroArch autoconfig ---"
adb push "$TEMPLATES/retroarch/GameSir-T3.cfg" /storage/emulated/0/RetroArch/autoconfig/android/
adb push "$TEMPLATES/retroarch/GameSir-Nova-Lite-2.cfg" /storage/emulated/0/RetroArch/autoconfig/android/

# Dolphin GCPad config
echo ""
echo "--- Dolphin GCPad ---"
DOLPHIN_DIR=$(adb shell "find /storage/emulated/0/Android/data/org.dolphinemu.dolphinemu/ -type d -name Config 2>/dev/null" | tr -d '\r')
if [ -n "$DOLPHIN_DIR" ]; then
    adb push "$TEMPLATES/dolphin/GCPadNew.ini" "$DOLPHIN_DIR/"
else
    echo "SKIP: Dolphin config dir not found. Launch Dolphin once first."
fi

# PPSSPP controls
echo ""
echo "--- PPSSPP controls ---"
PPSSPP_DIR=$(adb shell "find /storage/emulated/0/ -type d -path '*/PSP/SYSTEM' 2>/dev/null" | head -1 | tr -d '\r')
if [ -n "$PPSSPP_DIR" ]; then
    adb push "$TEMPLATES/ppsspp/controls.ini" "$PPSSPP_DIR/"
else
    echo "SKIP: PPSSPP SYSTEM dir not found. Launch PPSSPP once first."
fi

# AetherSX2 / NetherSX2
echo ""
echo "--- AetherSX2 (PS2) ---"
echo "NOTE: PCSX2.ini is a large file. The template is a PARTIAL file."
echo "      You must manually merge [Pad1]/[Pad2] sections into the existing PCSX2.ini."
echo "      Template at: $TEMPLATES/aethersx2/PCSX2.ini.partial"

# DuckStation
echo ""
echo "--- DuckStation (PS1) ---"
echo "NOTE: settings.ini is a large file. The template is a PARTIAL file."
echo "      You must manually merge [Pad1]/[Pad2] sections into the existing settings.ini."
echo "      Template at: $TEMPLATES/duckstation/settings.ini.partial"

# Flycast
echo ""
echo "--- Flycast (Dreamcast) ---"
FLYCAST_MAP="/storage/emulated/0/Android/data/com.flycast.emulator/files/data/mappings"
if adb shell "[ -d '$FLYCAST_MAP' ]" 2>/dev/null; then
    adb push "$TEMPLATES/flycast/GameSir-T3.cfg" "$FLYCAST_MAP/SDL_GameSir-T3 2.4G Gamepad.cfg"
    adb push "$TEMPLATES/flycast/GameSir-Nova-Lite-2.cfg" "$FLYCAST_MAP/SDL_GameSir-Nova Lite 2.cfg"
else
    echo "SKIP: Flycast mappings dir not found. Launch Flycast once first."
fi

# Redream
echo ""
echo "--- Redream (Dreamcast) ---"
echo "NOTE: redream.cfg is a full config file. The template is PARTIAL."
echo "      You must manually merge input/profile lines into the existing redream.cfg."
echo "      Template at: $TEMPLATES/redream/redream.cfg.partial"

# Citra
echo ""
echo "--- Citra (3DS) ---"
echo "NOTE: sdl2-config.ini is a large file. The template is PARTIAL."
echo "      You must manually merge [Controls] section into the existing file."
echo "      Template at: $TEMPLATES/citra/sdl2-config.ini.partial"

# Yaba Sanshiro
echo ""
echo "--- Yaba Sanshiro 2 (Saturn) ---"
for pkg in org.devmiyax.yabasanshioro2 org.devmiyax.yabasanshioro2.pro; do
    YABA_DIR="/storage/emulated/0/Android/data/$pkg/files/yabause"
    if adb shell "[ -d '$YABA_DIR' ]" 2>/dev/null; then
        adb push "$TEMPLATES/yabasanshiro/keymap_v2.json" "$YABA_DIR/"
        adb push "$TEMPLATES/yabasanshiro/keymap_player2_v2.json" "$YABA_DIR/"
        echo "Pushed to $YABA_DIR"
        break
    fi
done

# Mupen64Plus
echo ""
echo "--- Mupen64Plus (N64) ---"
echo "NOTE: Mupen64Plus FZ manages config via its own UI."
echo "      Template at: $TEMPLATES/mupen64plus/input-controllers.cfg"

echo ""
echo "Done! Force-stop and relaunch each emulator for changes to take effect."
echo "  adb shell am force-stop <package.name>"
