#!/usr/bin/env bash
# anim_loop.sh — Background animation state machine for the gone-fishing overlay.
#
# Usage: bash anim_loop.sh <mailbox_file> <fisherman_id> [term_cols]
#
# Args:
#   mailbox_file  — temp file path used as one-way mailbox from the main process
#   fisherman_id  — id from fishermen.json (e.g. "grizzled-pete")
#   term_cols     — terminal column count (pass when stdin is not a TTY)
#
# Mailbox protocol (main → loop):
#   Write `hooking:<color>:<fish_name>` on line 1.
#   Write fish ASCII art on line 2 (may be empty).
#   Loop clears the mailbox after reading.
#
# State machine:
#   idle → (mailbox triggers) → hooking (1000ms)
#        → retrieving (500ms/frame) → display (3000ms) → idle

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/anim_core.sh"
source "$SCRIPT_DIR/anim_frames.sh"
source "$SCRIPT_DIR/anim_renderer.sh"

MAILBOX_FILE="${1:?mailbox_file required}"
FISHERMAN_ID="${2:-grizzled-pete}"
TERM_COLS="${3:-}"
FISHERMEN_JSON="$HOME/.claude/commands/refs/gone-fishing/fishermen.json"

# ── Millisecond timer ─────────────────────────────────────────────────────────
# BSD date (macOS) does not support %3N. Detect at startup.
_init_timer() {
  if date +%s%3N >/dev/null 2>&1; then
    _now_ms() { date +%s%3N; }
  else
    _now_ms() { python3 -c 'import time; print(int(time.time()*1000))'; }
  fi
}
_init_timer

# ── Terminal width ────────────────────────────────────────────────────────────
if ! anim_check_terminal "$TERM_COLS"; then
  # Terminal too narrow or unknown — exit silently; no animation rendered.
  exit 0
fi

# ── Load frames ───────────────────────────────────────────────────────────────
if ! load_fisherman_frames "$FISHERMAN_ID" "$FISHERMEN_JSON"; then
  exit 1
fi

# ── State machine ─────────────────────────────────────────────────────────────
ANIM_STATE="idle"
STATE_ENTER_MS=$(_now_ms)
CURRENT_FISH_COLOR=15
CURRENT_FISH_NAME=""
CURRENT_FISH_ASCII=""
CURRENT_RETRIEVE_FRAME=0

# Render the initial idle frame
anim_render_frame ANIM_FRAME_IDLE 15

while true; do
  sleep 0.1
  now=$(_now_ms)
  elapsed=$(( now - STATE_ENTER_MS ))

  case "$ANIM_STATE" in

    idle)
      # Poll mailbox for a hooking trigger written by the main process.
      if [[ -f "$MAILBOX_FILE" && -s "$MAILBOX_FILE" ]]; then
        first_line=$(head -1 "$MAILBOX_FILE" 2>/dev/null || true)
        if [[ "$first_line" == hooking:* ]]; then
          fish_ascii=$(tail -n +2 "$MAILBOX_FILE" 2>/dev/null || true)
          IFS=: read -r _ fish_color fish_name <<< "$first_line"
          CURRENT_FISH_COLOR="${fish_color:-15}"
          CURRENT_FISH_NAME="$fish_name"
          CURRENT_FISH_ASCII="$fish_ascii"
          # Clear mailbox so we don't re-trigger
          printf '' > "$MAILBOX_FILE"
          ANIM_STATE="hooking"
          STATE_ENTER_MS=$(_now_ms)
          anim_render_frame ANIM_FRAME_HOOKING "$CURRENT_FISH_COLOR"
        fi
      fi
      ;;

    hooking)
      if (( elapsed >= 1000 )); then
        ANIM_STATE="retrieving"
        CURRENT_RETRIEVE_FRAME=0
        STATE_ENTER_MS=$(_now_ms)
        anim_render_frame ANIM_FRAME_RETRIEVING_0 "$CURRENT_FISH_COLOR"
      fi
      ;;

    retrieving)
      # Each retrieving sub-frame is held for 500ms.
      local_frame=$(( elapsed / 500 ))
      if (( local_frame >= ANIM_RETRIEVING_COUNT )); then
        # All sub-frames played — move to display.
        ANIM_STATE="display"
        STATE_ENTER_MS=$(_now_ms)
        anim_render_display "$CURRENT_FISH_NAME" "$CURRENT_FISH_ASCII" "$CURRENT_FISH_COLOR"
      elif (( local_frame != CURRENT_RETRIEVE_FRAME )); then
        # Advance to next sub-frame.
        CURRENT_RETRIEVE_FRAME=$local_frame
        anim_render_frame "ANIM_FRAME_RETRIEVING_${CURRENT_RETRIEVE_FRAME}" "$CURRENT_FISH_COLOR"
      fi
      ;;

    display)
      if (( elapsed >= 3000 )); then
        ANIM_STATE="idle"
        STATE_ENTER_MS=$(_now_ms)
        CURRENT_FISH_COLOR=15
        CURRENT_FISH_NAME=""
        CURRENT_FISH_ASCII=""
        anim_render_frame ANIM_FRAME_IDLE 15
      fi
      ;;

  esac
done
