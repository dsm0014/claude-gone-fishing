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
5. Print the stats display (see format below)

## Stats display format

```
╔══════════════════════════════════════════╗
║  🎣 Fishing Stats                        ║
╠══════════════════════════════════════════╣
║  Fisherman:  <Name>                      ║
║  ─────────────────────────────────────── ║
║  <Full backstory, word-wrapped at 40>    ║
╠══════════════════════════════════════════╣
║  Total catches:  <N>                     ║
║                                          ║
║  Recent catches:                         ║
║    • <Common Name>  (<rarity>)           ║
║    • ...                                 ║
╚══════════════════════════════════════════╝
```

- Show up to the 10 most recent catches, newest first
- If no catches: show `No fish caught yet.` in place of the catch list
