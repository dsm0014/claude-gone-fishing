#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMD_SRC="$REPO_ROOT/.claude/commands/gone-fishing"
CMD_DST="$HOME/.claude/commands"
DATA_DST="$HOME/.claude/commands/refs/gone-fishing"
STATUSLINE_SCRIPT="$HOME/.claude/statusline-command.sh"
HOOK_DIR="$HOME/.claude/hooks"
HOOK_SCRIPT="$HOOK_DIR/gone-fishing-session.sh"
CATCH_HOOK_SCRIPT="$HOOK_DIR/gone-fishing-catch.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "Installing gone-fishing command..."
echo "  commands -> $CMD_DST"
echo "  data     -> $DATA_DST"

mkdir -p "$CMD_DST"
mkdir -p "$DATA_DST/refs"
mkdir -p "$HOOK_DIR"

for f in gone-fishing.md fishing-stats.md new-fisherman.md; do
  cp "$CMD_SRC/$f" "$CMD_DST/$f"
  echo "  copied $f -> commands/"
done

for f in fish.json fishermen.json; do
  cp "$CMD_SRC/$f" "$DATA_DST/$f"
  echo "  copied $f -> commands/refs/gone-fishing/"
done

# ── Session hook ─────────────────────────────────────────────────────────────
echo "  writing gone-fishing-session.sh..."
cp "$REPO_ROOT/scripts/gone-fishing-session-hook.sh" "$HOOK_SCRIPT"
chmod +x "$HOOK_SCRIPT"
echo "  gone-fishing-session.sh written"

# ── Catch hook ────────────────────────────────────────────────────────────────
echo "  writing gone-fishing-catch.sh..."
cp "$REPO_ROOT/scripts/gone-fishing-catch-hook.sh" "$CATCH_HOOK_SCRIPT"
chmod +x "$CATCH_HOOK_SCRIPT"
echo "  gone-fishing-catch.sh written"

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
[ -n "$mode" ] && parts="$parts | $mode"

SESSION_FILE="$HOME/.claude/commands/refs/gone-fishing/refs/session.json"
STATE_FILE="$HOME/.claude/commands/refs/gone-fishing/refs/state.json"
if [ -f "$SESSION_FILE" ]; then
  fisher=$(jq -r '.fishermanName // empty' "$SESSION_FILE" 2>/dev/null)
  if [ -n "$fisher" ]; then
    CATCHES_FILE="$HOME/.claude/commands/refs/gone-fishing/refs/catches.json"
    total_exp=0
    if [ -f "$CATCHES_FILE" ]; then
        total_exp=$(jq '[.catches[].exp // 0] | add // 0' "$CATCHES_FILE" 2>/dev/null || echo 0)
    fi
    [ -z "$total_exp" ] || [ "$total_exp" = "null" ] && total_exp=0

    # Derive level (max 50). cumulative(n) = 25*(n-1)*(n+2)
    level=1
    for n in $(seq 2 50); do
        cum=$(( 25 * (n-1) * (n+2) ))
        if [ "$total_exp" -ge "$cum" ]; then level=$n; else break; fi
    done

    # Derive tier and ANSI color code
    tier=$(( (level - 1) / 5 + 1 ))
    [ "$tier" -gt 10 ] && tier=10
    case $tier in
        1) tier_code="" ;;
        2) tier_code="33" ;;
        3) tier_code="37" ;;
        4) tier_code="36" ;;
        5) tier_code="92" ;;
        6) tier_code="1;90" ;;
        7) tier_code="94" ;;
        8) tier_code="96" ;;
        9) tier_code="1;33" ;;
        10) tier_code="1;95" ;;
    esac
    if [ -n "$tier_code" ]; then
        colored_lure="$(printf '\033[%sm*\033[0m' "$tier_code")"
        active_level="$(printf '\033[%smLv.%s\033[0m' "$tier_code" "$level")"
    else
        colored_lure="*"
        active_level="Lv.${level}"
    fi
    inactive_level="Lv.${level}"

    activated_at=$(jq -r '.activatedAt // empty' "$SESSION_FILE" 2>/dev/null)
    activated_epoch=$(date -d "$activated_at" +%s 2>/dev/null || \
                      date -j -f "%Y-%m-%dT%H:%M:%SZ" "$activated_at" +%s 2>/dev/null || echo 0)
    age=$(( $(date +%s) - activated_epoch ))
    if [ "$age" -lt 28800 ]; then
      fish_state=$([ -f "$STATE_FILE" ] && jq -r '.state // "idle"' "$STATE_FILE" 2>/dev/null || echo "idle")
      if [ "$fish_state" = "caught" ]; then
        caught_at=$(jq -r '.caughtAt // empty' "$STATE_FILE" 2>/dev/null)
        if [ -n "$caught_at" ]; then
          caught_epoch=$(date -d "$caught_at" +%s 2>/dev/null || \
                         date -j -f "%Y-%m-%dT%H:%M:%SZ" "$caught_at" +%s 2>/dev/null || echo 0)
          catch_age=$(( $(date +%s) - caught_epoch ))
        else
          catch_age=0
        fi
        if [ "$catch_age" -ge 10 ]; then
          glyph="~~${colored_lure}~~"
        else
          fish_name=$(jq -r '.catch.common // ""' "$STATE_FILE" 2>/dev/null)
          fish_ascii=$(jq -r '.catch.ascii // ""' "$STATE_FILE" 2>/dev/null)
          fish_color=$(jq -r '.catch.color // ""' "$STATE_FILE" 2>/dev/null)
          if [ -n "$fish_color" ]; then
            fish_ascii="$(printf '\033[38;5;%sm%s\033[0m' "$fish_color" "$fish_ascii")"
          fi
          glyph="~>!<~  ${fish_name} ${fish_ascii}"
        fi
      else
        glyph="~~${colored_lure}~~"
      fi
    else
      glyph="~~~~~"
    fi
    if [ "$age" -lt 28800 ]; then
      parts="$parts | 🎣 ${fisher}  ${glyph}  ${active_level}"
    else
      parts="$parts | 🎣 ${fisher}  ~~~~~  ${inactive_level}"
    fi
  fi
fi

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
SESSION_HOOK_ENTRY='{"matcher":"","hooks":[{"type":"command","command":"'"$HOOK_SCRIPT"'"}]}'
CATCH_HOOK_ENTRY='{"matcher":"","hooks":[{"type":"command","command":"'"$CATCH_HOOK_SCRIPT"'"}]}'
if [ -f "$SETTINGS_FILE" ]; then
  tmp=$(mktemp)
  jq --arg s "$STATUSLINE_SCRIPT" --argjson perms "$FISHING_PERMS" \
     --argjson hook "$SESSION_HOOK_ENTRY" \
     --argjson catch_hook "$CATCH_HOOK_ENTRY" '
    .statusLine = {type: "command", command: $s} |
    .permissions.allow = ((.permissions.allow // []) + $perms | unique) |
    .hooks.UserPromptSubmit = (
      (.hooks.UserPromptSubmit // []) |
      map(select(.hooks[0].command != $hook.hooks[0].command)) + [$hook]
    ) |
    .hooks.Stop = (
      (.hooks.Stop // []) |
      map(select(.hooks[0].command != $catch_hook.hooks[0].command)) + [$catch_hook]
    )
  ' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
else
  jq -n --arg s "$STATUSLINE_SCRIPT" --argjson perms "$FISHING_PERMS" \
     --argjson hook "$SESSION_HOOK_ENTRY" \
     --argjson catch_hook "$CATCH_HOOK_ENTRY" '{
    statusLine: {type: "command", command: $s},
    permissions: {allow: $perms},
    hooks: {
      UserPromptSubmit: [$hook],
      Stop: [$catch_hook]
    }
  }' > "$SETTINGS_FILE"
fi
echo "  settings.json updated"

echo "Done. Run /gone-fishing once to assign your fisherman — every session after that starts automatically."
