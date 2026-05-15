#!/usr/bin/env bash
# anim_frames.sh — Loads fisherman animation frames from fishermen.json into bash arrays.
#
# Populates after load_fisherman_frames():
#   ANIM_FRAME_IDLE[]             — idle pose lines
#   ANIM_FRAME_HOOKING[]          — hooking pose lines
#   ANIM_FRAME_DISPLAY[]          — display (catch reveal) pose lines
#   ANIM_FRAME_RETRIEVING_0[]     — first retrieving sub-frame lines
#   ANIM_FRAME_RETRIEVING_N[]     — additional sub-frames if present in JSON
#   ANIM_RETRIEVING_COUNT         — number of retrieving sub-frames loaded
#
# Requires: jq

# ── mapfile shim (bash 3.2 / macOS compatibility) ────────────────────────────
# macOS ships bash 3.2 which lacks mapfile/readarray. This shim reproduces the
# subset we need: `mapfile -t ARRNAME < <(...)`.
_gf_readarray() {
  local _arr="$1" _line _i=0
  while IFS= read -r _line; do
    eval "${_arr}[$((_i))]=\"\$_line\""
    _i=$((_i + 1))
  done
}

if ! declare -f mapfile &>/dev/null; then
  mapfile() {
    # Usage: mapfile -t ARRNAME
    # $1=-t  $2=array_name  reads from stdin
    _gf_readarray "$2"
  }
fi

# ── Frame validation ──────────────────────────────────────────────────────────
# _validate_frame <array_name> <max_len>
# Warns and truncates any line in the named array that exceeds max_len chars.
_validate_frame() {
  local arr_name="$1"
  local max_len="${2:-22}"
  local arr_len i line len
  eval "arr_len=\${#${arr_name}[@]}"
  for (( i=0; i<arr_len; i++ )); do
    eval "line=\"\${${arr_name}[$i]}\""
    len=${#line}
    if (( len > max_len )); then
      echo "anim_frames: warning: frame line too long (${len}>${max_len}), truncating: '${line}'" >&2
      eval "${arr_name}[$i]=\"\${line:0:${max_len}}\""
    fi
  done
}

# ── Main loader ───────────────────────────────────────────────────────────────
# load_fisherman_frames <fisherman_id> [fishermen_json_path]
# Exits non-zero if the fisherman is not found or jq is unavailable.
load_fisherman_frames() {
  local fisherman_id="$1"
  local json_path="${2:-$HOME/.claude/commands/refs/gone-fishing/fishermen.json}"

  if ! command -v jq &>/dev/null; then
    echo "anim_frames: jq is required but not found in PATH" >&2
    return 1
  fi

  if [[ ! -f "$json_path" ]]; then
    echo "anim_frames: fishermen.json not found: $json_path" >&2
    return 1
  fi

  # Validate fisherman exists
  local name
  name=$(jq -r --arg id "$fisherman_id" '.[] | select(.id == $id) | .name' "$json_path" 2>/dev/null)
  if [[ -z "$name" ]]; then
    echo "anim_frames: fisherman '$fisherman_id' not found in $json_path" >&2
    return 1
  fi

  # Load idle
  mapfile -t ANIM_FRAME_IDLE < <(
    jq -r --arg id "$fisherman_id" \
      '.[] | select(.id == $id) | .frames.idle[]' \
      "$json_path"
  )
  _validate_frame ANIM_FRAME_IDLE

  # Load hooking
  mapfile -t ANIM_FRAME_HOOKING < <(
    jq -r --arg id "$fisherman_id" \
      '.[] | select(.id == $id) | .frames.hooking[]' \
      "$json_path"
  )
  _validate_frame ANIM_FRAME_HOOKING

  # Load display
  mapfile -t ANIM_FRAME_DISPLAY < <(
    jq -r --arg id "$fisherman_id" \
      '.[] | select(.id == $id) | .frames.display[]' \
      "$json_path"
  )
  _validate_frame ANIM_FRAME_DISPLAY

  # Load retrieving sub-frames.
  # Current fishermen.json stores retrieving as a single flat array of lines —
  # one animation pose. Future entries may have an array-of-arrays for multi-step
  # retrieval; detect which schema is present and load accordingly.
  local retrieving_type
  retrieving_type=$(jq -r --arg id "$fisherman_id" \
    '.[] | select(.id == $id) | .frames.retrieving | if type == "array" then (if (.[0] | type) == "array" then "nested" else "flat" end) else "unknown" end' \
    "$json_path" 2>/dev/null)

  ANIM_RETRIEVING_COUNT=0

  if [[ "$retrieving_type" == "nested" ]]; then
    # Array of arrays — each sub-array is one animation frame
    local sub_count
    sub_count=$(jq -r --arg id "$fisherman_id" \
      '.[] | select(.id == $id) | .frames.retrieving | length' \
      "$json_path")
    for (( fi=0; fi<sub_count; fi++ )); do
      mapfile -t "ANIM_FRAME_RETRIEVING_${fi}" < <(
        jq -r --arg id "$fisherman_id" --argjson idx "$fi" \
          '.[] | select(.id == $id) | .frames.retrieving[$idx][]' \
          "$json_path"
      )
      _validate_frame "ANIM_FRAME_RETRIEVING_${fi}"
    done
    ANIM_RETRIEVING_COUNT=$sub_count
  else
    # Flat array of lines — single animation pose
    mapfile -t ANIM_FRAME_RETRIEVING_0 < <(
      jq -r --arg id "$fisherman_id" \
        '.[] | select(.id == $id) | .frames.retrieving[]' \
        "$json_path"
    )
    _validate_frame ANIM_FRAME_RETRIEVING_0
    ANIM_RETRIEVING_COUNT=1
  fi

  export ANIM_FRAME_IDLE ANIM_FRAME_HOOKING ANIM_FRAME_DISPLAY ANIM_RETRIEVING_COUNT
}
