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
# Claude Code status line: model | context % | effort/thinking | fisherman
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
if [ -n "$mode" ]; then
  parts="$parts | $mode"
fi

STATE_FILE="$HOME/.claude/commands/refs/gone-fishing/refs/state.json"
if [ -f "$STATE_FILE" ]; then
  fisher=$(jq -r '.fishermanName // empty' "$STATE_FILE" 2>/dev/null)
  state=$(jq -r '.state // "idle"' "$STATE_FILE" 2>/dev/null)
  if [ -n "$fisher" ]; then
    if [ "$state" = "caught" ]; then
      fish_name=$(jq -r '.catch.common // ""' "$STATE_FILE" 2>/dev/null)
      fish_ascii=$(jq -r '.catch.ascii // ""' "$STATE_FILE" 2>/dev/null)
      fish_color=$(jq -r '.catch.color // ""' "$STATE_FILE" 2>/dev/null)
      if [ -n "$fish_color" ]; then
        fish_ascii="$(printf '\033[38;5;%sm%s\033[0m' "$fish_color" "$fish_ascii")"
      fi
      fishing="🎣 ${fisher}  ~|!!  ${fish_name} ${fish_ascii}"
    else
      fishing="🎣 ${fisher}  ~|°"
    fi
    parts="$parts | $fishing"
  fi
fi

printf "%s" "$parts"
EOF
chmod +x "$STATUSLINE_SCRIPT"
echo "  statusline-command.sh written"

# ── settings.json ────────────────────────────────────────────────────────────
echo "  updating settings.json..."
FISHING_PERMS='[
  "Read(~/.claude/commands/refs/gone-fishing/**)",
  "Write(~/.claude/commands/refs/gone-fishing/refs/**)",
  "Bash(mv ~/.claude/commands/refs/gone-fishing/refs/*.tmp ~/.claude/commands/refs/gone-fishing/refs/*)",
  "Bash(bash ~/.claude/commands/refs/gone-fishing/lib/anim_loop.sh*)",
  "Write(/tmp/gone-fishing-anim-*)"
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
