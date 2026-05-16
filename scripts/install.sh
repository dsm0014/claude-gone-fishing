#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMD_SRC="$REPO_ROOT/.claude/commands/gone-fishing"
LIB_SRC="$REPO_ROOT/lib"
CMD_DST="$HOME/.claude/commands"
DATA_DST="$HOME/.claude/commands/refs/gone-fishing"
STATUSLINE_SCRIPT="$HOME/.claude/statusline-command.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing gone-fishing command..."
echo "  commands -> $CMD_DST"
echo "  data     -> $DATA_DST"

mkdir -p "$CMD_DST"
mkdir -p "$DATA_DST/refs"
mkdir -p "$DATA_DST/lib"

for f in gone-fishing.md fishing-stats.md new-fisherman.md; do
  cp "$CMD_SRC/$f" "$CMD_DST/$f"
  echo "  copied $f -> commands/"
done

for f in fish.json fishermen.json; do
  cp "$CMD_SRC/$f" "$DATA_DST/$f"
  echo "  copied $f -> commands/refs/gone-fishing/"
done

for f in anim_core.sh anim_frames.sh anim_renderer.sh anim_loop.sh; do
  cp "$LIB_SRC/$f" "$DATA_DST/lib/$f"
  chmod +x "$DATA_DST/lib/$f"
  echo "  copied $f -> commands/refs/gone-fishing/lib/"
done

# ── Statusline ───────────────────────────────────────────────────────────────
echo "  writing statusline-command.sh..."
cat > "$STATUSLINE_SCRIPT" << 'EOF'
#!/usr/bin/env bash
# Claude Code status line: ASCII fisherman (multi-line, right-aligned) + model info
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  ctx=$(printf "ctx:%.0f%%" "$used")
else
  ctx="ctx:--"
fi
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
if [ -n "$effort_level" ]; then
  mode="effort:${effort_level}"
elif [ "$thinking" = "true" ]; then
  mode="thinking:on"
else
  mode=""
fi
parts="$model | $ctx"
[ -n "$mode" ] && parts="$parts | $mode"

REFS="$HOME/.claude/commands/refs/gone-fishing"
PROFILE="$REFS/refs/profile.json"
STATE_FILE="$REFS/refs/state.json"
FISHERMEN_FILE="$REFS/fishermen.json"

if [ ! -f "$PROFILE" ] || [ ! -f "$STATE_FILE" ]; then
  printf '%s' "$parts"
  exit 0
fi

fisherman_id=$(jq -r '.fishermanId // ""' "$PROFILE" 2>/dev/null)
if [ -z "$fisherman_id" ]; then
  printf '%s' "$parts"
  exit 0
fi

fish_state=$(jq -r '.state // "idle"' "$STATE_FILE" 2>/dev/null)
anim_start=$(jq -r '.animStartAt // 0' "$STATE_FILE" 2>/dev/null)
NOW=$(date +%s)
elapsed=$(( NOW - ${anim_start:-0} ))

frame_key="idle"
if [ "$fish_state" = "caught" ]; then
  if [ "$elapsed" -lt 2 ]; then
    frame_key="hooking"
  elif [ "$elapsed" -lt 4 ]; then
    frame_key="retrieving"
  else
    frame_key="display"
  fi
fi

mapfile -t ART_LINES < <(jq -r \
  --arg id "$fisherman_id" --arg key "$frame_key" \
  '.[] | select(.id == $id) | .frames[$key][]' \
  "$FISHERMEN_FILE" 2>/dev/null)

if [ ${#ART_LINES[@]} -eq 0 ]; then
  printf '%s' "$parts"
  exit 0
fi

if [ "$frame_key" = "display" ] && [ "$fish_state" = "caught" ]; then
  fish_ascii=$(jq -r '.catch.ascii // ""' "$STATE_FILE" 2>/dev/null)
  fish_color=$(jq -r '.catch.color // 15' "$STATE_FILE" 2>/dev/null)
  fish_name=$(jq -r '.catch.common // ""' "$STATE_FILE" 2>/dev/null)
  fish_exp=$(jq -r '.catch.exp // 0' "$STATE_FILE" 2>/dev/null)
  colored_fish=$(printf '\033[38;5;%sm%s\033[0m' "$fish_color" "$fish_ascii")
  ART_LINES[0]="${ART_LINES[0]}  ${colored_fish}"
  if [ "${#ART_LINES[@]}" -gt 1 ]; then
    ART_LINES[1]="${ART_LINES[1]}  ${fish_name} (+${fish_exp})"
  fi
fi

# Terminal width via parent process TTY chain (same technique as claude-buddy)
COLS=0
_pid=$$
for _ in 1 2 3 4 5; do
  _pid=$(ps -o ppid= -p "$_pid" 2>/dev/null | tr -d ' ')
  [ -z "$_pid" ] || [ "$_pid" = "1" ] && break
  _pty=$(readlink "/proc/${_pid}/fd/0" 2>/dev/null)
  if [ -c "$_pty" ] 2>/dev/null; then
    COLS=$(stty size < "$_pty" 2>/dev/null | awk '{print $2}')
    { [ "${COLS:-0}" -gt 40 ] 2>/dev/null && break; } || true
  fi
  _tty=$(ps -o tty= -p "$_pid" 2>/dev/null | tr -d ' ')
  if [ -n "$_tty" ] && [ "$_tty" != "??" ] && [ "$_tty" != "?" ]; then
    _tty_dev="/dev/$_tty"
    if [ -c "$_tty_dev" ] 2>/dev/null; then
      COLS=$(stty size < "$_tty_dev" 2>/dev/null | awk '{print $2}')
      { [ "${COLS:-0}" -gt 40 ] 2>/dev/null && break; } || true
    fi
  fi
done
[ "${COLS:-0}" -lt 40 ] && COLS=$(tput cols 2>/dev/null)
[ "${COLS:-0}" -lt 40 ] && COLS=${COLUMNS:-80}

ART_W=0
for _line in "${ART_LINES[@]}"; do
  [ "${#_line}" -gt "$ART_W" ] && ART_W="${#_line}"
done

MARGIN=8
PAD=$(( COLS - ART_W - MARGIN ))
[ "$PAD" -lt 0 ] && PAD=0

B=$'\xe2\xa0\x80'  # Braille Blank U+2800 — survives Claude Code's whitespace trim
SPACER=$(printf "${B}%${PAD}s" "")
NC=$'\033[0m'
C=$'\033[38;5;15m'

# Extend water rows (ending with ~) to fill into the right margin
_wlen=$(( MARGIN - 3 ))
if [ "$_wlen" -gt 0 ]; then
  _wfill=$(printf '~%.0s' $(seq 1 "$_wlen"))
  for i in "${!ART_LINES[@]}"; do
    case "${ART_LINES[$i]}" in *'~') ART_LINES[$i]="${ART_LINES[$i]}${_wfill}" ;; esac
  done
fi

for _line in "${ART_LINES[@]}"; do
  printf '%s%s%s\n' "$SPACER" "${C}${_line}${NC}"
done

printf '%s' "$parts"
EOF
chmod +x "$STATUSLINE_SCRIPT"
echo "  statusline-command.sh written"

# ── settings.json ────────────────────────────────────────────────────────────
echo "  updating settings.json..."
FISHING_PERMS='[
  "Read(~/.claude/commands/refs/gone-fishing/**)",
  "Write(~/.claude/commands/refs/gone-fishing/refs/**)",
  "Bash(mv ~/.claude/commands/refs/gone-fishing/refs/*.tmp ~/.claude/commands/refs/gone-fishing/refs/*)"
]'
if [ -f "$SETTINGS_FILE" ]; then
  tmp=$(mktemp)
  jq --arg s "$STATUSLINE_SCRIPT" --argjson perms "$FISHING_PERMS" '
    .statusLine = {type: "command", command: $s} |
    .permissions.allow = ((.permissions.allow // []) + $perms | unique)
  ' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
else
  jq -n --arg s "$STATUSLINE_SCRIPT" --argjson perms "$FISHING_PERMS" '{
    statusLine: {type: "command", command: $s},
    permissions: {allow: $perms}
  }' > "$SETTINGS_FILE"
fi
echo "  settings.json updated"

echo "Done. Run /gone-fishing in Claude Code to start."
