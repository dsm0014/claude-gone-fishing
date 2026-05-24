# Skill: /fishing-stats (System Prompt)

**Tags:** skill, command, stats, display, level, EXP, history, rarity

This article documents the **actual Claude system prompt** loaded when a user invokes `/fishing-stats` — the Markdown skill definition at `.claude/commands/gone-fishing/fishing-stats.md`. It specifies the exact computation steps Claude performs at runtime (level formula, EXP bar fill algorithm, aggregate derivations) and the precise panel layout. For the feature-level design intent — section descriptions, edge cases, and acceptance criteria — see [[fishing-stats-command]].

## Purpose

`/fishing-stats` can be invoked at any time, regardless of whether a `/gone-fishing` session is active. It reads `profile.json` and `catches.json` from `~/.claude/commands/refs/gone-fishing/refs/`, derives all metrics at runtime, and renders a fixed-width panel to the terminal.

## Input Files

| File | Path | Used for |
|---|---|---|
| `fishermen.json` | `~/.claude/commands/refs/gone-fishing/fishermen.json` | Resolve fisherman name and full backstory |
| `fish.json` | `~/.claude/commands/refs/gone-fishing/fish.json` | Pool size denominator for unique-species count |
| `profile.json` | `refs/profile.json` | Active `fishermanId` |
| `catches.json` | `refs/catches.json` | All catch records; source of all computed metrics |

See [[persistence-layer]] for full schemas.

## Step-by-Step Execution (exact runtime sequence)

1. Read `refs/profile.json`. If missing: print `No fisherman selected yet. Run /gone-fishing to meet yours!` and stop.
2. Load the matching entry from `fishermen.json` using `fishermanId`.
3. Read `refs/catches.json`. If missing or corrupt: treat as empty array.
4. Compute level, rod tier, and EXP bar (see formulas below).
5. Compute aggregate statistics (see below).
6. Render the stats panel.

## Level and EXP Bar Formulas

All metrics are derived from `catches[].exp`; nothing is read from stored level fields.

```
totalExp       = sum of all catches[].exp
cumulative(n)  = 25 * (n - 1) * (n + 2)
level          = highest n ≤ 50 where cumulative(n) ≤ totalExp
expIntoLevel   = totalExp - cumulative(level)
expNeeded      = 100 + (level - 1) * 50
fillCount      = floor(20 * expIntoLevel / expNeeded)
```

The EXP bar is 20 characters wide: `fillCount` × `█` followed by `(20 - fillCount)` × `░`. The `Lv.NN` label and the fill characters are rendered in the ANSI color for the current rod tier. See [[leveling-system]] for the full tier table (Willow Branch at tier 1 through Celestial Rod at tier 10). At level 50 the fraction is replaced with `MAX`.

## Aggregate Computations

| Metric | Derivation |
|---|---|
| `uniqueSpecies` | Count of distinct `fishId` values in `catches[]` |
| `poolSize` | Entry count in `fish.json` |
| `firstCatch` | Minimum `timestamp`, formatted `YYYY-MM-DD` in local time |
| `lastCatch` | Maximum `timestamp`, formatted `YYYY-MM-DD` in local time |
| `rarityCounts` | Group `catches[]` by `rarity` field |
| `topSpecies` | Top 3 `fishId` values by catch count; display as `common` name |
| `recentCatches` | Last 3 catches, newest first |

All timestamps display in local time, not UTC. See [[persistence-layer]] for how `common` and `rarity` are denormalized at catch time, ensuring these reads are always consistent even after `fish.json` edits.

## Panel Layout (exact format)

```
╔══════════════════════════════════════╗
║        🎣  Fishing Stats             ║
╠══════════════════════════════════════╣
║  Fisherman:  <Name>                  ║
║  <backstory, word-wrapped 40 chars>  ║
╠══════════════════════════════════════╣
║  Level: <N>  <Rod Tier Name>         ║
║  <Lv.NN ████████░░░░>               ║
║  <NNN / NNN XP>                      ║
╠══════════════════════════════════════╣
║  Total Catches:     <N>              ║
║  Unique Species:    <N> / <pool>     ║
║  Total EXP Earned:  <N,NNN>          ║
║  First Catch:       <YYYY-MM-DD>     ║
║  Last Catch:        <YYYY-MM-DD>     ║
╠══════════════════════════════════════╣
║  Catches by Rarity                   ║
║  Common: <N>  Uncommon: <N>          ║
║  Rare:   <N>  Legendary: <N>         ║
╠══════════════════════════════════════╣
║  Top Catches                         ║
║  1. <Name>  ×<N>                     ║
║  2. <Name>  ×<N>                     ║
║  3. <Name>  ×<N>                     ║
╠══════════════════════════════════════╣
║  Recent Catches                      ║
║  • <Name>  <YYYY-MM-DD HH:MM>        ║
╚══════════════════════════════════════╝
```

**Rendering notes (from skill file):**
- EXP bar label: `Lv.NN` + two spaces + fill + empty. Render label and fill in tier ANSI color.
- Level 50: show `MAX` instead of the `current / threshold` fraction.
- Omit the Top Catches and Recent Catches sections entirely if `catches[]` is empty.
- All timestamps in local time.

## Edge Cases

| Condition | Behavior |
|---|---|
| `profile.json` missing | Print prompt to run `/gone-fishing`; stop |
| `catches.json` missing or corrupt | Treat as empty array |
| No catches yet | Omit Top Catches and Recent Catches sections |
| Level 50 | Full bar, `MAX` label, no fraction |
| `poolSize` | Denominator taken from actual `fish.json` count, not hardcoded |

## Related

- [[fishing-stats-command]] — spec-level design, section descriptions, and acceptance criteria
- [[skill-gone-fishing]] — the `/gone-fishing` skill that initiates sessions
- [[skill-new-fisherman]] — the `/new-fisherman` skill that changes the displayed character
- [[leveling-system]] — `cumulative(n)` formula, rod tier names, and ANSI color table
- [[persistence-layer]] — `catches.json` and `profile.json` schemas; denormalization rationale
- [[fisherman-roster]] — backstory content and word-wrap constraints
- [[fish-database]] — pool size used for unique-species denominator
