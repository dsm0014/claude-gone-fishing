#!/usr/bin/env bash
# UserPromptSubmit hook: auto-activates gone-fishing each session if profile exists.
# Writes session.json once per session (within 8 hours); injects fishing context.
REFS="$HOME/.claude/commands/refs/gone-fishing/refs"
PROFILE="$REFS/profile.json"

[ -f "$PROFILE" ] || exit 0

SESSION="$REFS/session.json"
NOW_EPOCH=$(date +%s)

if [ -f "$SESSION" ]; then
  activated_at=$(jq -r '.activatedAt // empty' "$SESSION" 2>/dev/null)
  if [ -n "$activated_at" ]; then
    activated_epoch=$(date -d "$activated_at" +%s 2>/dev/null || \
                      date -j -f "%Y-%m-%dT%H:%M:%SZ" "$activated_at" +%s 2>/dev/null || echo 0)
    age=$(( NOW_EPOCH - activated_epoch ))
    if [ "$age" -lt 28800 ]; then
      fisher_name=$(jq -r '.fishermanName // empty' "$SESSION" 2>/dev/null)
      STATE_FILE="$REFS/state.json"
      if [ -f "$STATE_FILE" ]; then
        fish_state=$(jq -r '.state // empty' "$STATE_FILE" 2>/dev/null)
        if [ "$fish_state" = "caught" ]; then
          caught_at=$(jq -r '.caughtAt // empty' "$STATE_FILE" 2>/dev/null)
          last_announced=$(jq -r '.lastAnnouncedCatchAt // empty' "$SESSION" 2>/dev/null)
          if [ -n "$caught_at" ] && { [ -z "$last_announced" ] || [[ "$caught_at" > "$last_announced" ]]; }; then
            TMP="$SESSION.tmp"
            jq --arg t "$caught_at" '. + {lastAnnouncedCatchAt: $t}' "$SESSION" > "$TMP" && mv "$TMP" "$SESSION"
            fish_common=$(jq -r '.catch.common // ""' "$STATE_FILE" 2>/dev/null)
            fish_ascii=$(jq -r '.catch.ascii // ""' "$STATE_FILE" 2>/dev/null)
            fish_exp=$(jq -r '.catch.exp // ""' "$STATE_FILE" 2>/dev/null)
            printf '[gone-fishing] NEW CATCH: %s %s (+%s EXP) — mention this at the start of your response.\n' \
              "$fish_common" "$fish_ascii" "$fish_exp"
          fi
        fi
      fi
      printf '[gone-fishing] %s is on the line.\n' "$fisher_name"
      exit 0
    fi
  fi
fi

FISHERMEN="$HOME/.claude/commands/refs/gone-fishing/fishermen.json"
fisher_id=$(jq -r '.fishermanId // empty' "$PROFILE" 2>/dev/null)
fisher_name=$(jq -r --arg id "$fisher_id" '.[] | select(.id == $id) | .name' "$FISHERMEN" 2>/dev/null)

[ -n "$fisher_name" ] || exit 0

NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP="$SESSION.tmp"
printf '{"version":1,"fishermanId":"%s","fishermanName":"%s","activatedAt":"%s"}\n' \
  "$fisher_id" "$fisher_name" "$NOW_ISO" > "$TMP" && mv "$TMP" "$SESSION"

printf '[gone-fishing] %s is on the line.\n' "$fisher_name"
