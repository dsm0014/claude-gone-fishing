# Spec 08 — Leveling System

**Status:** `TODO`
**Depends on:** [03 Catch Probability](./03-catch-probability.md), [04 Fish Database](./04-fish-database.md), [06 Persistence Layer](./06-persistence.md)

---

## Purpose

Defines how fishing experience (EXP) accrues from catches, how the fisherman advances through 50 levels, and how progression is communicated visually through the statusline. Level is expressed as a color applied to the lure glyph (`*`) and the level label (`Lv.NN`) in the statusline — the same color, so both read as one visual unit. No ASCII art frame changes are part of this spec.

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

## Lure & Level Color Tiers

Every 5 levels the lure color upgrades. The tier color applies to two things in the statusline: the lure glyph (`*`) and the level label (`Lv.NN`). Both render in the same color so they read as a matched pair.

| Levels | Tier | Name | ANSI Escape |
|--------|------|------|-------------|
| 1–4 | 1 | Willow Branch | none (default) |
| 5–9 | 2 | Bamboo Rod | `\e[33m` dim yellow |
| 10–14 | 3 | Fiberglass Rod | `\e[37m` light gray |
| 15–19 | 4 | Spinning Rod | `\e[36m` cyan |
| 20–24 | 5 | Baitcaster | `\e[92m` bright green |
| 25–29 | 6 | Carbon Fiber | `\e[1;90m` bold dark gray |
| 30–34 | 7 | Fly Rod | `\e[94m` bright blue |
| 35–39 | 8 | Surf Rod | `\e[96m` bright cyan |
| 40–44 | 9 | Gilded Rod | `\e[1;33m` bold yellow (gold) |
| 45–50 | 10 | Celestial Rod | `\e[1;95m` bold bright magenta |

The color jump is the primary signal that a tier has changed. The first four tiers are subtle; tiers 6–10 are increasingly vivid.

Rod tier is derived from level at render time — never stored separately:

```
rodTier = floor((currentLevel - 1) / 5) + 1   // clamps to 10 at level 50
```

---

## Statusline Integration

The statusline script (`statusline-command.sh`) reads `catches.json` on each tick to derive the current level and rod tier. It then applies the tier color to the lure glyph and level label.

### Active session (between turns)

```
🎣 Kodiak Karl  ~~[TIER_COLOR]*[RESET]~~  [TIER_COLOR]Lv.5[RESET]
```

Example at tier 2 (dim yellow):

```
🎣 Kodiak Karl  ~~\e[33m*\e[0m~~  \e[33mLv.7\e[0m
```

### Caught state

```
🎣 Kodiak Karl  ~>!<~  [FISH_COLOR]Bluefin Tuna ><(((°>[RESET]  [TIER_COLOR]Lv.5[RESET]
```

The level label remains visible during a catch display.

### Inactive state (profile exists, session not started)

```
🎣 Kodiak Karl  ~~~~~  Lv.5
```

No color applied in the inactive state — the lure is not in the water.

### No profile

Falls back gracefully; shows model/ctx only with no fishing elements.

### Implementation note

Computing level from `catches.json` on every statusline tick is acceptable — the file is small and the read is local. The statusline script must handle a missing `catches.json` (new user, no catches yet) by defaulting to level 1, tier 1.

---

## EXP Bar Display

Shown in `/fishing-stats` output. Not rendered inline during conversation turns.

### Format

```
Lv.12  ████████████░░░░░░░░  800 / 1100 XP
```

- **Label:** `Lv.NN` (right-padded to 6 chars), rendered in the current tier color
- **Bar:** 20-character block — filled `█`, empty `░`, rendered in tier color
  - Fill count = `floor(20 * expIntoLevel / expNeeded)`
- **Fraction:** `NNNN / NNNN XP` (no leading zeros)
- At level 50: `Lv.50  ████████████████████  MAX` (full bar, no fraction)

---

## Level-Up Notification

When a catch pushes the fisherman to a new level, the skill emits a one-time inline notification as part of the catch response, before the updated EXP context:

```
★ LEVEL UP! Kodiak Karl reached Level 10! ★
    Rod upgraded → Fiberglass Rod
```

The new tier name is included so the color change in the statusline has a name to anchor it to.

---

## Persistence Changes

EXP is fully reconstructed from `catches.json` at runtime. No separate EXP or level field is stored in `profile.json`. This keeps the persistence layer append-only and audit-friendly.

---

## Acceptance Criteria

- [ ] Each fish in `fish.json` has an `exp` field within its tier range.
- [ ] Level is derived from total EXP in `catches.json` — not stored separately.
- [ ] Statusline shows `Lv.NN` in the current tier color next to the lure glyph.
- [ ] Lure glyph `*` in `~~*~~` renders in the current tier color.
- [ ] Lure glyph and level label share the same ANSI color (read as a matched pair).
- [ ] No tier color is applied in the inactive state (`~~~~~`).
- [ ] Level label remains visible during the caught state display.
- [ ] Tier color updates immediately on the next statusline tick after a level-crossing catch.
- [ ] Missing `catches.json` defaults to level 1, tier 1 (no color) without error.
- [ ] EXP bar renders correctly in `/fishing-stats` with accurate fill, fraction, and tier-colored label.
- [ ] EXP bar shows `MAX` at level 50 with a full bar.
- [ ] Level-up notification fires inline when a catch advances the level, naming the new tier.
- [ ] At level 50 cap, further catches still log EXP but the bar reads `MAX` and no level-up fires.
