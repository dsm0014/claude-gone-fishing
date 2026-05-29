#!/usr/bin/env bash
set -euo pipefail

REFS="$HOME/.claude/commands/refs/gone-fishing/refs"
DATA="$HOME/.claude/commands/refs/gone-fishing"
SESSION="$REFS/session.json"
PROFILE="$REFS/profile.json"
STATE="$REFS/state.json"
CATCHES="$REFS/catches.json"
FISH_JSON="$DATA/fish.json"

# ── Session gate ──────────────────────────────────────────────────────────────
[ -f "$SESSION" ] || exit 0
activated_at=$(jq -r '.activatedAt // empty' "$SESSION" 2>/dev/null)
[ -n "$activated_at" ] || exit 0
NOW_EPOCH=$(date +%s)
activated_epoch=$(date -d "$activated_at" +%s 2>/dev/null || \
                  date -j -f "%Y-%m-%dT%H:%M:%SZ" "$activated_at" +%s 2>/dev/null || echo 0)
age=$(( NOW_EPOCH - activated_epoch ))
[ "$age" -lt 14400 ] || exit 0

# ── Profile gate ──────────────────────────────────────────────────────────────
[ -f "$PROFILE" ] || exit 0

# ── Catch roll ────────────────────────────────────────────────────────────────
roll=$(( RANDOM % 1000 ))
[ "$roll" -lt 100 ] || exit 0

# ── Time period + season ──────────────────────────────────────────────────────
hour=$(( 10#$(date +%H) ))
month=$(( 10#$(date +%m) ))

if   [ "$hour" -ge 5 ]  && [ "$hour" -le 8 ];  then period="dawn"
elif [ "$hour" -ge 9 ]  && [ "$hour" -le 16 ]; then period="day"
elif [ "$hour" -ge 17 ] && [ "$hour" -le 20 ]; then period="dusk"
else period="night"
fi

if   [ "$month" -ge 3 ] && [ "$month" -le 5 ];  then season="spring"
elif [ "$month" -ge 6 ] && [ "$month" -le 8 ];  then season="summer"
elif [ "$month" -ge 9 ] && [ "$month" -le 11 ]; then season="fall"
else season="winter"
fi

# ── Weighted fish selection ───────────────────────────────────────────────────
# 30-bit random for normalized float roll into [0, totalWeight)
rng=$(( (RANDOM << 15) | RANDOM ))

selected_fish=$(jq -c \
  --arg period "$period" \
  --arg season "$season" \
  --argjson rng "$rng" '
  def bw: {common: 60, uncommon: 25, rare: 12, legendary: 3};
  def tm: {
    dawn:  {common: 0.8,  uncommon: 1.2, rare: 1.5, legendary: 2.0},
    day:   {common: 1.2,  uncommon: 1.0, rare: 0.8, legendary: 0.5},
    dusk:  {common: 0.8,  uncommon: 1.2, rare: 1.5, legendary: 1.5},
    night: {common: 0.7,  uncommon: 1.3, rare: 1.8, legendary: 2.5}
  };
  def sm: {
    freshwater: {spring: 1.4, summer: 1.0, fall: 1.2, winter: 0.5},
    saltwater:  {spring: 1.0, summer: 1.3, fall: 1.1, winter: 0.8},
    brackish:   {spring: 1.1, summer: 1.1, fall: 1.1, winter: 0.7},
    "deep-sea": {spring: 1.0, summer: 1.0, fall: 1.0, winter: 1.0},
    tropical:   {spring: 0.9, summer: 1.5, fall: 0.8, winter: 0.4},
    arctic:     {spring: 0.6, summer: 0.3, fall: 0.8, winter: 1.8}
  };
  [.[] | {f: ., w: ((bw[.rarity] // 1) * (tm[$period][.rarity] // 1.0) * (sm[.habitat][$season] // 1.0))}] as $pool |
  ($pool | map(.w) | add) as $total |
  ($rng / 1073741824.0 * $total) as $r |
  reduce $pool[] as $item (
    {acc: 0.0, found: null};
    if .found != null then .
    else (.acc + $item.w) as $a |
      if $a > $r then {acc: $a, found: $item.f}
      else {acc: $a, found: null}
      end
    end
  ) | .found
' "$FISH_JSON" 2>/dev/null) || exit 0

[ -n "$selected_fish" ] && [ "$selected_fish" != "null" ] || exit 0

_f=()
while IFS= read -r line; do
  _f+=("$line")
done < <(echo "$selected_fish" | jq -r '.id, .common, .ascii, (.color|tostring), (.exp|tostring), .rarity')
fish_id="${_f[0]:-}"
fish_common="${_f[1]:-}"
fish_ascii="${_f[2]:-}"
fish_color="${_f[3]:-0}"
fish_exp="${_f[4]:-0}"
fish_rarity="${_f[5]:-common}"

[ -n "$fish_id" ] || exit 0

# ── Pre-catch level detection ─────────────────────────────────────────────────
prev_total=0
if [ -f "$CATCHES" ]; then
  _pt=$(jq '[.catches[].exp // 0] | add // 0' "$CATCHES" 2>/dev/null || echo 0)
  if [ -n "$_pt" ] && [ "$_pt" != "null" ]; then prev_total=$(( _pt )); fi
fi

prev_level=1
for n in $(seq 2 50); do
  cum=$(( 25 * (n - 1) * (n + 2) ))
  if [ "$prev_total" -ge "$cum" ]; then prev_level=$n; else break; fi
done

# ── Write state.json ──────────────────────────────────────────────────────────
fisher_name=$(jq -r '.fishermanName // "Fisherman"' "$SESSION" 2>/dev/null)
NOW_ISO=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -n \
  --arg fishermanName "$fisher_name" \
  --arg caughtAt "$NOW_ISO" \
  --arg fishId "$fish_id" \
  --arg common "$fish_common" \
  --arg ascii "$fish_ascii" \
  --argjson color "$fish_color" \
  --argjson exp "$fish_exp" \
  '{version:1, fishermanName:$fishermanName, state:"caught", caughtAt:$caughtAt,
    catch:{fishId:$fishId, common:$common, ascii:$ascii, color:$color, exp:$exp}}' \
  > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

# ── Append catches.json ───────────────────────────────────────────────────────
existing='{"version":1,"catches":[]}'
if [ -f "$CATCHES" ] && jq . "$CATCHES" >/dev/null 2>&1; then
  existing=$(cat "$CATCHES")
fi

echo "$existing" | jq \
  --arg fishId "$fish_id" \
  --arg common "$fish_common" \
  --arg rarity "$fish_rarity" \
  --argjson exp "$fish_exp" \
  --arg timestamp "$NOW_ISO" \
  '.catches += [{fishId:$fishId, common:$common, rarity:$rarity, exp:$exp, timestamp:$timestamp}]' \
  > "$CATCHES.tmp" && mv "$CATCHES.tmp" "$CATCHES"

# ── Level-up check ────────────────────────────────────────────────────────────
new_total=$(( prev_total + fish_exp ))
new_level=1
for n in $(seq 2 50); do
  cum=$(( 25 * (n - 1) * (n + 2) ))
  if [ "$new_total" -ge "$cum" ]; then new_level=$n; else break; fi
done

if [ "$new_level" -gt "$prev_level" ]; then
  tier=$(( (new_level - 1) / 5 + 1 ))
  [ "$tier" -gt 10 ] && tier=10
  case $tier in
    1) tier_name="Willow Branch" ;;
    2) tier_name="Bamboo Rod" ;;
    3) tier_name="Fiberglass Rod" ;;
    4) tier_name="Spinning Rod" ;;
    5) tier_name="Baitcaster" ;;
    6) tier_name="Carbon Fiber" ;;
    7) tier_name="Fly Rod" ;;
    8) tier_name="Surf Rod" ;;
    9) tier_name="Gilded Rod" ;;
   10) tier_name="Celestial Rod" ;;
  esac
  jq --argjson levelUpTo "$new_level" --arg levelUpTier "$tier_name" \
    '. + {levelUpTo: $levelUpTo, levelUpTier: $levelUpTier}' \
    "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
fi

# ── Catch notification ────────────────────────────────────────────────────────
printf '🎣 %s  %s  (+%s EXP)\n' "$fish_common" "$fish_ascii" "$fish_exp"
