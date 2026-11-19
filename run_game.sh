#!/bin/bash
# PROJECT: PROTO-BREACH - Game Launcher
# Launches the game using the local Godot 4.3 runtime

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT_BIN="$SCRIPT_DIR/bin/godot"

if [ ! -f "$GODOT_BIN" ]; then
    echo "[ERROR] Godot binary not found at $GODOT_BIN"
    exit 1
fi

echo "============================================="
echo "  Launching PROTO-BREACH: BLACKWOOD PINES"
echo "  Map: Deadwood Forest - Outpost Alpha"
echo "  Engine: Godot 4.3 (GL Compatibility)"
echo "============================================="

cd "$SCRIPT_DIR"
"$GODOT_BIN" levels/zombie_outbreak/Blackwood_Pines.tscn "$@"
