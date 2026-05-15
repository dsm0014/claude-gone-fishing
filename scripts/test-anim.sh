#!/usr/bin/env bash
# test-anim.sh — Standalone test for the gone-fishing animation system.
#
# Runs Grizzled Pete through the full state sequence:
#   idle (2s) → hooking (1s) → retrieving (0.5s/frame) → display (3s) → idle
#
# Usage: bash scripts/test-anim.sh [fisherman_id]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$REPO_ROOT/lib"
FISHERMEN_JSON="$REPO_ROOT/.claude/commands/gone-fishing/fishermen.json"

FISHERMAN_ID="${1:-grizzled-pete}"

# ── Load library files ────────────────────────────────────────────────────────
source "$LIB_DIR/anim_core.sh"
source "$LIB_DIR/anim_frames.sh"
source "$LIB_DIR/anim_renderer.sh"

# ── Terminal width check ──────────────────────────────────────────────────────
echo "=== gone-fishing animation test ==="
echo "Fisherman: $FISHERMAN_ID"
echo ""

TERM_COLS=$(tput cols 2>/dev/null || echo 0)
echo "Terminal width: $TERM_COLS columns (need $ANIM_MIN_WIDTH+)"

if ! anim_check_terminal "$TERM_COLS"; then
  echo "WARNING: Terminal too narrow — forcing ANIM_START_COL to a safe default."
  echo "         Frames will render at column 91. Widen to 120+ for proper layout."
  ANIM_START_COL=91
  export ANIM_START_COL
fi

echo "Rendering region starts at column $ANIM_START_COL"
echo ""

# ── Load frames ───────────────────────────────────────────────────────────────
echo "Loading frames..."
load_fisherman_frames "$FISHERMAN_ID" "$FISHERMEN_JSON"
echo "  idle lines:       ${#ANIM_FRAME_IDLE[@]}"
echo "  hooking lines:    ${#ANIM_FRAME_HOOKING[@]}"
echo "  retrieving count: $ANIM_RETRIEVING_COUNT sub-frame(s)"
echo "  display lines:    ${#ANIM_FRAME_DISPLAY[@]}"
echo ""
echo "Starting animation sequence in 1 second..."
sleep 1

# ── Idle ──────────────────────────────────────────────────────────────────────
echo "[IDLE — 2s]"
anim_render_frame ANIM_FRAME_IDLE 15
sleep 2

# ── Hooking ───────────────────────────────────────────────────────────────────
echo "[HOOKING — 1s]"
anim_render_frame ANIM_FRAME_HOOKING 15
sleep 1

# ── Retrieving ────────────────────────────────────────────────────────────────
for (( i=0; i<ANIM_RETRIEVING_COUNT; i++ )); do
  echo "[RETRIEVING frame $i — 0.5s]"
  anim_render_frame "ANIM_FRAME_RETRIEVING_${i}" 15
  sleep 0.5
done

# ── Display ───────────────────────────────────────────────────────────────────
echo "[DISPLAY — 3s  (Atlantic Bluefin Tuna)]"
# color 214 = orange; ASCII art from fish.json for demo purposes
anim_render_display "Atlantic Bluefin Tuna" "><)))*>" 214
sleep 3

# ── Return to idle ────────────────────────────────────────────────────────────
echo "[IDLE — return]"
anim_render_frame ANIM_FRAME_IDLE 15
sleep 1

# ── Cleanup ───────────────────────────────────────────────────────────────────
anim_clear_region

echo ""
echo "=== Animation test complete ==="
