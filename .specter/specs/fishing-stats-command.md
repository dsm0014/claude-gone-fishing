# /fishing-stats Command

**Tags:** command, stats, display, level, history

**Spec:** 05 — Status: DONE

The `/fishing-stats` slash command displays a summary of the user's lifetime fishing history. It can be invoked at any time — the `/gone-fishing` session does not need to be active.

## Output Layout

```
╔══════════════════════════════════════╗
║           🎣 Fishing Stats           ║
╠══════════════════════════════════════╣
║  Fisherman:  Grizzled Pete           ║
║                                      ║
║  Pete spent forty years on Lake      ║
║  Superior before his boat sank ...   ║
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

## Sections

| Section | Content |
|---|---|
| Fisherman | Current character's name and full backstory, word-wrapped to the panel width |
| Level | Current level number, rod tier name, EXP progress bar (20-char block), and `current / threshold XP` fraction |
| Summary | Total catches, unique species count vs pool size, total lifetime EXP, date of first and last catch |
| Catches by Rarity | Count of each rarity tier: Common, Uncommon, Rare, Legendary |
| Top Catches | Top 3 most-caught species with repeat count |
| Recent Catches | Last 3 catches with timestamp in local time |

## EXP Bar Format

```
Lv.12  ████████████░░░░░░░░  800 / 1100 XP
```

- Label `Lv.NN` rendered in the current rod tier color (see [[leveling-system]]).
- 20-character block: filled `█`, empty `░`, fill count = `floor(20 × expIntoLevel / expNeeded)`.
- At level 50: `Lv.50  ████████████████████  MAX` (full bar, no fraction).

## Data Source

The command reads `catches.json` from `~/.claude/commands/refs/gone-fishing/refs/`. Level, EXP, and rod tier are derived at runtime — none are stored directly. See [[leveling-system]] for derivation logic and [[persistence-layer]] for the `catches.json` schema.

## Edge Cases

- **No catches yet:** `No fish caught yet. Run /gone-fishing to start!`
- **No fisherman assigned:** `No fisherman selected yet. Run /gone-fishing to meet yours!`
- **Missing refs directory:** Same as no catches — treat as empty history, do not error.
- Species count denominator reflects the actual fish pool size, not a hardcoded 100.
- Timestamps display in local time, not UTC.

## Related

- [[persistence-layer]] — catches.json and profile.json read by this command
- [[leveling-system]] — level derivation, rod tier names, EXP bar format
- [[fisherman-roster]] — character name, type, and backstory displayed in the Fisherman section
- [[fish-database]] — species pool size used for the unique-species denominator
