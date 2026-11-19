#!/bin/bash
# PROJECT: PROTO-BREACH - Godot Editor Launcher
# Opens the Godot 4.3 Editor for this project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODOT_BIN="$SCRIPT_DIR/bin/godot"

if [ ! -f "$GODOT_BIN" ]; then
    echo "[ERROR] Godot binary not found at $GODOT_BIN"
    exit 1
fi

echo "============================================="
echo "  Opening PROJECT: PROTO-BREACH in Godot 4.3"
echo "============================================="

cd "$SCRIPT_DIR"
"$GODOT_BIN" -e "$@"
