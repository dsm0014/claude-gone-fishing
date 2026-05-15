# Spec 08 — Leveling System

**Status:** `TODO`
**Depends on:** [03 Catch Probability](./03-catch-probability.md), [04 Fish Database](./04-fish-database.md), [06 Persistence Layer](./06-persistence.md)

---

## Purpose

Defines how fishing experience (EXP) accrues from catches, how the fisherman advances through 50 levels, and how leveling up visually upgrades the fishing rod in all ASCII art frames.

---

## EXP Per Catch

Each fish entry in `fish.json` carries a base `exp` value. EXP is awarded immediately when a catch is logged.

### EXP Tiers

| Tier | Examples | EXP Range |
|------|----------|-----------|
| Common freshwater | Bluegill, Perch, Sunfish | 15–30 |
| Common saltwater | Mackerel, Herring, Flounder | 25–45 |
| Sport / game fish | Largemouth Bass, Rainbow Trout, Mahi-Mahi | 40–75 |
| Rare / trophy | Tarpon, Giant Trevally, Arapaima | 70–120 |
| Deep sea / exotic | Anglerfish, Viperfish, Oarfish | 100–175 |
| Legendary | Coelacanth, Paddlefish, Taimen | 175–250 |

Assign each fish a fixed `exp` value at authoring time — not derived at runtime.

---

## Level Thresholds

50 total levels. Each level's required XP uses a **linear progression**:

```
threshold(n) = 100 + (n - 1) * 50
```

| Level | XP required for this level | Cumulative XP to reach |
|-------|---------------------------|------------------------|
| 1 | 100 | 0 |
| 2 | 150 | 100 |
| 3 | 200 | 250 |
| 5 | 300 | 750 |
| 10 | 550 | 2,875 |
| 15 | 800 | 6,875 |
| 20 | 1,050 | 11,500 |
| 30 | 1,550 | 24,750 |
| 40 | 2,050 | 43,250 |
| 50 | 2,550 | 66,750 |

At heavy usage (~5 catches/day, average ~60 XP each = 300 XP/day):

- **Level 10:** ~9.6 days
- **Level 20:** ~38 days (over one month ✓)
- **Level 50:** ~222 days (~7.5 months)

Level 50 is the cap — no further leveling; EXP display reads `MAX`.

### Level-Up Logic

```
totalExp = sum of all exp from catches.json
currentLevel = highest n where cumulative_threshold(n) <= totalExp
expIntoLevel = totalExp - cumulative_threshold(currentLevel)
expNeeded = threshold(currentLevel + 1)   // 0 if level 50
```

Level is always derived from total lifetime EXP — never stored as a raw number. This means retroactive EXP edits or fish rebalancing self-correct automatically.

---

## EXP Bar Display

Rendered below the fisherman ASCII art during the idle frame and after each catch. Always shown when `/gone-fishing` is active.

### Format

```
Lv.12  ████████████░░░░░░░░  800 / 1100 XP
```

- **Label:** `Lv.NN` (right-padded to 6 chars)
- **Bar:** 20-character block — filled `█`, empty `░`
  - Fill count = `floor(20 * expIntoLevel / expNeeded)`
- **Fraction:** `NNNN / NNNN XP` (no leading zeros; right-aligned to the widest number in the current tier)
- At level 50: `Lv.50  ████████████████████  MAX`

### Placement

The EXP bar is rendered as a single line directly below the fisherman's last ASCII frame row, at the same right-margin offset. It is part of the fisherman's render block, not inline with Claude's text.

### Level-Up Notification

When a catch pushes the fisherman to a new level, display a one-time inline notification **before** the normal EXP bar:

```
★ LEVEL UP! Grizzled Pete reached Level 13! ★
    Rod upgraded → Carbon Fiber Spinning Rod
```

Then render the updated EXP bar showing the new level (possibly `0 / next_threshold XP`).

---

## Rod Upgrade Tiers

Every 5 levels the fishing rod visually upgrades. The rod tier governs which rod ASCII art is used in all four animation frames (idle, hooking, retrieving, display). Each fisherman character must have rod-art variants for all 10 tiers.

| Levels | Rod Tier | Name | Visual Character |
|--------|----------|------|-----------------|
| 1–4 | 1 | Willow Branch | `\` with a short wiggly line |
| 5–9 | 2 | Bamboo Rod | `\|` — straight, notched |
| 10–14 | 3 | Fiberglass Rod | `\\` — two-tone |
| 15–19 | 4 | Spinning Rod | `\=` with small reel indicator |
| 20–24 | 5 | Baitcaster | `\≡` with reel and guide rings |
| 25–29 | 6 | Carbon Fiber | `\#` — sleek, dark |
| 30–34 | 7 | Fly Rod | long `\~~~~` with a tapered tip |
| 35–39 | 8 | Surf Rod | extra-long `\‾‾‾` with heavy guides |
| 40–44 | 9 | Gilded Rod | `\$` — ornate with gold trim |
| 45–50 | 10 | Celestial Rod | `\★` — glowing, star-tipped |

### Rod Art Implementation

Each fisherman's `frames` object gains a `rodTier` override mechanism. The skill replaces the rod-region characters in the pre-authored ASCII frames with tier-appropriate characters at render time.

Rod tier is derived from level at render time — it is not stored separately.

```
rodTier = floor((currentLevel - 1) / 5) + 1   // clamps to 10 at level 50
```

---

## Persistence Changes

EXP is fully reconstructed from `catches.json` at runtime (see level-up logic above). No separate EXP field is stored in `profile.json`. This keeps the persistence layer append-only and audit-friendly.

---

## Acceptance Criteria

- [ ] Each fish in `fish.json` has an `exp` field within its tier range.
- [ ] EXP bar renders correctly at idle with accurate fill, fraction, and level label.
- [ ] EXP bar shows `MAX` at level 50 with a full bar.
- [ ] Level is derived from total EXP in `catches.json` — not stored separately.
- [ ] Level-up notification fires inline when a catch advances the level, naming the new rod tier.
- [ ] Rod tier changes every 5 levels (1→2 at level 5, 2→3 at level 10, …).
- [ ] All 10 rod tiers are visually distinct in ASCII art.
- [ ] EXP bar placement does not collide with Claude's text output.
- [ ] At level 50 cap, further catches still log EXP but the bar reads `MAX` and no level-up fires.
