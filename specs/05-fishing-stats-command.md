# Spec 05 — /fishing-stats Command

**Status:** `DONE`
**Depends on:** [06 Persistence Layer](./06-persistence.md), [04 Fish Database](./04-fish-database.md), [07 Fisherman Roster](./07-fisherman-roster.md), [08 Leveling System](./08-leveling-system.md)

---

## Purpose

The `/fishing-stats` slash command displays a summary of the user's lifetime fishing history across all sessions.

## Behavior

### Activation
- User invokes `/fishing-stats` at any time (does not require `/gone-fishing` to be active).
- Claude reads the catch log from `~/.claude/commands/refs/gone-fishing/refs/` and renders the stats view inline in the conversation.

### Stats View Layout

```
╔══════════════════════════════════════╗
║           🎣 Fishing Stats           ║
╠══════════════════════════════════════╣
║  Fisherman:  Grizzled Pete           ║
║                                      ║
║  Pete spent forty years on Lake      ║
║  Superior before his boat sank in    ║
║  a storm he swears he predicted.     ║
║  He fishes now not for sport or      ║
║  food, but because standing still    ║
║  makes his knees ache and the water  ║
║  doesn't ask questions.              ║
╠══════════════════════════════════════╣
║  Level:   12  Carbon Fiber Rod       ║
║  Lv.12  ████████████░░░░░░░░         ║
║                                      ║
║  800 / 1100 XP                       ║
╠══════════════════════════════════════╣
║  Total Catches:        42            ║
║  Unique Species:       31 / 100      ║
║  Total EXP Earned:     3,240         ║
║  First Catch:          2026-05-14    ║
║  Last Catch:           2026-05-17    ║
╠══════════════════════════════════════╣
║  Catches by Rarity                   ║
║  Common:    28    Uncommon:  10      ║
║  Rare:       3    Legendary:  1      ║
╠══════════════════════════════════════╣
║  Top Catches                         ║
║  1. Rainbow Trout         ×5         ║
║  2. Largemouth Bass       ×4         ║
║  3. Atlantic Bluefin Tuna ×3         ║
╠══════════════════════════════════════╣
║  Recent Catches                      ║
║  • Mahi-Mahi       2026-05-17 14:22  ║
║  • Swordfish       2026-05-16 09:11  ║
║  • Coelacanth      2026-05-15 22:47  ║
╚══════════════════════════════════════╝
```

### Sections

| Section | Description |
|---------|-------------|
| Fisherman | Current character's name and full backstory paragraph (word-wrapped) |
| Level | Current level, rod tier name, and EXP progress bar (see [Spec 08](./08-leveling-system.md)) |
| Summary | Total catches, unique species count vs pool size, total lifetime EXP, date range |
| Catches by Rarity | Count of catches in each rarity tier: Common, Uncommon, Rare, Legendary |
| Top Catches | Top 3 most-caught species with count |
| Recent Catches | Last 3 catches with timestamp |

### Edge Cases

- **No catches yet:** Display a friendly message — `No fish caught yet. Run /gone-fishing to start!`
- **Missing refs directory:** Same as no catches — treat as empty history, do not error.

## Skill File

**Path:** `~/.claude/commands/fishing-stats.md`

The skill reads `~/.claude/commands/refs/gone-fishing/refs/catches.json`, aggregates the data, and renders the stats table inline.

## Acceptance Criteria

- [x] `/fishing-stats` works with no active `/gone-fishing` session.
- [x] Fisherman section shows current character name and full backstory.
- [x] If no fisherman is assigned yet, fisherman section shows `No fisherman selected yet. Run /gone-fishing to meet yours!`
- [x] Level section shows correct level, rod tier name, EXP bar fill, and `current / threshold XP`.
- [x] EXP bar shows `MAX` at level 50.
- [x] All stat sections render correctly when data exists.
- [x] Summary shows total lifetime EXP earned.
- [x] Catches by Rarity section shows correct counts for all four tiers.
- [x] Friendly empty-state message shows when no catches are recorded.
- [x] Species count denominator reflects the actual fish pool size.
- [x] Timestamps display in local time (not UTC).
