#!/usr/bin/env bash
# anim_core.sh — ANSI helpers, terminal width guard, cursor positioning
#
# Source this file before using any anim_* functions.
# Requires: ANIM_START_COL to be set (via anim_check_terminal).

ANIM_MIN_WIDTH=120
ANIM_COLS=30
ANIM_ROWS=8

# anim_check_terminal
# Returns 0 and sets ANIM_START_COL if terminal is wide enough; returns 1 otherwise.
# Accepts an optional override width as $1 (useful when stdin is not a TTY).
anim_check_terminal() {
  local cols="${1:-}"
  if [[ -z "$cols" ]]; then
    cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 0)}
  fi
  [[ "$cols" -ge "$ANIM_MIN_WIDTH" ]] || return 1
  ANIM_START_COL=$(( cols - ANIM_COLS + 1 ))
  export ANIM_START_COL
}

anim_save_cursor()    { printf '\x1b[s'; }
anim_restore_cursor() { printf '\x1b[u'; }
anim_move()           { printf '\x1b[%d;%dH' "$1" "$2"; }
anim_color()          { printf '\x1b[38;5;%dm' "$1"; }
anim_reset()          { printf '\x1b[0m'; }

# anim_clear_region
# Erases each row of the fisherman's bounding box without touching the left side.
anim_clear_region() {
  local row
  anim_save_cursor
  for (( row=1; row<=ANIM_ROWS; row++ )); do
    anim_move "$row" "$ANIM_START_COL"
    printf '\x1b[K'   # erase from cursor to end of line only
  done
  anim_restore_cursor
}
