---
name: fishing-stats
description: Displays the current fisherman's name, full backstory, and complete catch history across all sessions, including total catches, EXP, level, and the 10 most recent fish caught.
user-invocable: true
---

# /fishing-stats

You are the fishing-stats skill. Display the current fisherman's profile and all catch history.

## Steps

1. Data: `~/.claude/commands/refs/gone-fishing/` — `fishermen.json`
   Refs: `~/.claude/commands/refs/gone-fishing/refs/` — `profile.json`, `catches.json`
2. Read `refs/profile.json`. If missing, print: `No fisherman assigned yet. Run /gone-fishing first.` and stop.
3. Load the matching fisherman from `fishermen.json` using `fishermanId`
4. Read `refs/catches.json`. If missing or corrupt, treat catches as empty array.
5. Compute level and EXP bar:
   - totalExp = sum of all catches[].exp
   - Derive level using cumulative(n) = 25*(n-1)*(n+2); level = highest n ≤ 50 where cumulative(n) ≤ totalExp
   - expIntoLevel = totalExp - cumulative(level)
   - expNeeded = 100 + (level - 1) * 50  (0 if level 50)
   - fillCount = floor(20 * expIntoLevel / expNeeded)  (20 if level 50)
   - Derive tier and ANSI color using the tier table in gone-fishing.md
   - Render: ANSI-colored "Lv.NN" + "  " + filled bar (█) + empty bar (░) + "  " + fraction or "MAX"
6. Print the stats display (see format below)

## Stats display format

```
╔══════════════════════════════════════════╗
║  🎣 Fishing Stats                        ║
╠══════════════════════════════════════════╣
║  Fisherman:  <Name>                      ║
║  ─────────────────────────────────────── ║
║  <Full backstory, word-wrapped at 40>    ║
╠══════════════════════════════════════════╣
║  Lv.<N>  ████████████░░░░░░░░  800/1100 XP ║
║                                          ║
║  Total catches:  <N>                     ║
║                                          ║
║  Recent catches:                         ║
║    • <Common Name>  (<rarity>)           ║
║    • ...                                 ║
╚══════════════════════════════════════════╝
```

- Show up to the 10 most recent catches, newest first
- If no catches: show `No fish caught yet.` in place of the catch list
- The EXP bar label (`Lv.NN`) and bar characters (`█`/`░`) render in the current tier ANSI color, reset after. If tier 1 (levels 1–4), render in default color (no escape code).
