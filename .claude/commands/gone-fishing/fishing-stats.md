---
name: fishing-stats
description: Displays the current fisherman's name, full backstory, and complete catch history across all sessions, including total catches, EXP, level, and the 10 most recent fish caught.
user-invocable: true
---

# /fishing-stats

You are the fishing-stats skill. Display the current fisherman's profile and all catch history.

## Steps

1. Data: `~/.claude/commands/refs/gone-fishing/` — `fishermen.json`, `fish.json`
   Refs: `~/.claude/commands/refs/gone-fishing/refs/` — `profile.json`, `catches.json`

2. Read `refs/profile.json`. If missing or the refs directory does not exist, print:
   `No fisherman selected yet. Run /gone-fishing to meet yours!` and stop.

3. Load the matching fisherman from `fishermen.json` using `fishermanId`.

4. Read `refs/catches.json`. If missing, corrupt, or the refs directory does not exist, treat catches as an empty array — no error.

5. Compute level, rod tier, and EXP bar:
   - `totalExp` = sum of all `catches[].exp`
   - `cumulative(n)` = `25 * (n - 1) * (n + 2)`; `level` = highest n ≤ 50 where `cumulative(n) ≤ totalExp`
   - `expIntoLevel` = `totalExp - cumulative(level)`
   - `expNeeded` = `100 + (level - 1) * 50`  (0 if level 50)
   - `fillCount` = `floor(20 * expIntoLevel / expNeeded)`  (20 if level 50)
   - Rod tier and ANSI color from the tier table in `gone-fishing.md` (no escape code for tier 1)
   - Tier names: 1=Willow Branch, 2=Bamboo Rod, 3=Fiberglass Rod, 4=Spinning Rod, 5=Baitcaster, 6=Carbon Fiber Rod, 7=Fly Rod, 8=Surf Rod, 9=Gilded Rod, 10=Celestial Rod

6. Compute aggregates from the catches array:
   - `uniqueSpecies` = count of distinct `fishId` values in catches
   - `poolSize` = count of entries in `fish.json`
   - `firstCatch` / `lastCatch` = min/max `timestamp`, formatted as `YYYY-MM-DD` in **local time**
   - `rarityCounts` = group catches by `rarity` → counts for common, uncommon, rare, legendary
   - `topSpecies` = group by `fishId`, sort descending by count, take top 3 — display `catches[].common` as name
   - `recentCatches` = last 3 catches (newest first) — display `common` + `timestamp` as `YYYY-MM-DD HH:MM` in local time

7. Print the stats display (see format below).

## Stats display format

```
╔══════════════════════════════════════╗
║        🎣  Fishing Stats             ║
╠══════════════════════════════════════╣
║  Fisherman:  <Name>                  ║
║                                      ║
║  <Full backstory, word-wrapped       ║
║  at 40 chars per line>               ║
╠══════════════════════════════════════╣
║  Level: <N>  <Rod Tier Name>         ║
║  <ANSI-colored Lv.NN ████████░░░░>  ║
║  <NNN / NNN XP>                      ║
╠══════════════════════════════════════╣
║  Total Catches:     <N>              ║
║  Unique Species:    <N> / <pool>     ║
║  Total EXP Earned:  <N,NNN>          ║
║  First Catch:       <YYYY-MM-DD>     ║
║  Last Catch:        <YYYY-MM-DD>     ║
╠══════════════════════════════════════╣
║  Catches by Rarity                   ║
║  Common:   <N>   Uncommon:  <N>      ║
║  Rare:     <N>   Legendary: <N>      ║
╠══════════════════════════════════════╣
║  Top Catches                         ║
║  1. <Name>               ×<N>        ║
║  2. <Name>               ×<N>        ║
║  3. <Name>               ×<N>        ║
╠══════════════════════════════════════╣
║  Recent Catches                      ║
║  • <Name>    <YYYY-MM-DD HH:MM>      ║
║  • <Name>    <YYYY-MM-DD HH:MM>      ║
║  • <Name>    <YYYY-MM-DD HH:MM>      ║
╚══════════════════════════════════════╝
```

### Rendering notes

- EXP bar: `Lv.NN` + two spaces + `fillCount` × `█` + `(20 - fillCount)` × `░`. Render label and bar characters in the tier ANSI color; reset after. No escape code for tier 1.
- At level 50: show `MAX` instead of the fraction.
- Total EXP Earned: format with comma thousands separators.
- Omit Top Catches section if fewer than 1 catch. Show up to 3 entries.
- Omit Recent Catches section if no catches. Show up to 3 entries.
- If no catches at all: after the Level section, print `No fish caught yet. Run /gone-fishing to start!` and omit the remaining sections.
- All timestamps display in local time (convert from UTC ISO 8601).
