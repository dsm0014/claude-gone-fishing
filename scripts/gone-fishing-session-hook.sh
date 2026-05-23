#!/usr/bin/env bash
# UserPromptSubmit hook: auto-activates gone-fishing each session if profile exists.
# Writes session.json once per session (within 8 hours); injects fishing context
# into the conversation so Claude applies the per-turn catch roll without /gone-fishing.
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
      printf '[gone-fishing] %s is on the line. Apply the per-turn catch roll after responding.\n' "$fisher_name"
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

printf '[gone-fishing] %s is on the line. Apply the per-turn catch roll after responding.\n' "$fisher_name"
