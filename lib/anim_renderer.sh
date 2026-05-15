#!/usr/bin/env bash
# anim_renderer.sh — Paints animation frames to the terminal at the far-right column.
#
# Requires: anim_core.sh (sourced first), ANIM_START_COL set.
# All functions save/restore the cursor so Claude's output is unaffected.

# anim_render_frame <array_name> [fish_color]
# Renders any named frame array (idle, hooking, retrieving_N) at ANIM_START_COL.
# Uses eval indirection to work on bash 3.2 (no namerefs).
anim_render_frame() {
  local arr_name="$1"
  local fish_color="${2:-15}"
  local row=1 line arr_len i=0

  anim_save_cursor
  anim_clear_region

  while true; do
    eval "arr_len=\${#${arr_name}[@]}"
    [[ $arr_len -gt $i ]] || break
    eval "line=\"\${${arr_name}[$i]}\""
    anim_move "$row" "$ANIM_START_COL"
    anim_color "$fish_color"
    printf '%s' "$line"
    anim_reset
    row=$(( row + 1 ))
    i=$(( i + 1 ))
  done

  anim_restore_cursor
}

# anim_render_display <fish_name> <fish_ascii> [fish_color]
# Renders ANIM_FRAME_DISPLAY with the caught fish name and ASCII art injected:
#   line 0: frame art + "  " + fish_ascii
#   line 1: frame art + "  " + fish_name
#   line 2+: frame art as-is
anim_render_display() {
  local fish_name="$1"
  local fish_ascii="$2"
  local fish_color="${3:-15}"
  local row=1 line arr_len i=0

  anim_save_cursor
  anim_clear_region

  eval "arr_len=\${#ANIM_FRAME_DISPLAY[@]}"

  while (( i < arr_len )); do
    eval "line=\"\${ANIM_FRAME_DISPLAY[$i]}\""
    anim_move "$row" "$ANIM_START_COL"
    anim_color "$fish_color"
    if (( i == 0 )); then
      printf '%s  %s' "$line" "$fish_ascii"
    elif (( i == 1 )); then
      printf '%s  %s' "$line" "$fish_name"
    else
      printf '%s' "$line"
    fi
    anim_reset
    row=$(( row + 1 ))
    i=$(( i + 1 ))
  done

  anim_restore_cursor
}
