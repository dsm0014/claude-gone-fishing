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

Every 5 levels the fishing rod visually upgrades. The rod tier governs which rod ASCII art **and color** is used in all four animation frames (idle, hooking, retrieving, display). Each fisherman character must have rod-art variants for all 10 tiers.

| Levels | Tier | Name | Visual Character | ANSI Color |
|--------|------|------|-----------------|------------|
| 1–4 | 1 | Willow Branch | `\` with a short wiggly line | none (default) |
| 5–9 | 2 | Bamboo Rod | `\|` — straight, notched | `\e[33m` dim yellow |
| 10–14 | 3 | Fiberglass Rod | `\\` — two-tone | `\e[37m` light gray |
| 15–19 | 4 | Spinning Rod | `\=` with small reel indicator | `\e[36m` cyan |
| 20–24 | 5 | Baitcaster | `\≡` with reel and guide rings | `\e[92m` bright green |
| 25–29 | 6 | Carbon Fiber | `\#` — sleek, dark | `\e[1;90m` bold dark gray |
| 30–34 | 7 | Fly Rod | long `\~~~~` with a tapered tip | `\e[94m` bright blue |
| 35–39 | 8 | Surf Rod | extra-long `\‾‾‾` with heavy guides | `\e[96m` bright cyan |
| 40–44 | 9 | Gilded Rod | `\$` — ornate with gold trim | `\e[1;33m` bold yellow (gold) |
| 45–50 | 10 | Celestial Rod | `\★` — glowing, star-tipped | `\e[1;95m` bold bright magenta |

The color jump is the primary signal that a rod tier has changed — it should be immediately obvious even in a glance. The first four tiers are subtle; tiers 6–10 are increasingly vivid.

### Rod Color Implementation

Color wraps every rod character in all four frame states. The reset (`\e[0m`) is appended immediately after the last rod character in each row so body/water characters are unaffected.

```
// Pseudocode — applied at render time, not stored in frame data
rodColor = ROD_COLORS[rodTier]   // ANSI escape string, or "" for tier 1
colorize = (s) => rodColor + s + (rodColor ? "\e[0m" : "")
```

**Which characters get colorized:**
- The rod shaft: all `/` and `\` characters that form the rod body
- The rod tip and special characters: `★`, `$`, `≡`, `=`, `#`, `~~~~`, `‾‾‾`
- The fishing line (`|` hanging from rod tip) — same color as the rod, so the whole rig reads as one unit

**Tier 10 exception:** At Celestial Rod, the fish display frame's raised-arms row (`\(o)/`) also renders the `\` and `/` arm-characters in bold magenta, as if the rod's energy has transferred to the fisherman's whole pose.

### Rod Art Derivation

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
- [ ] All 10 rod tiers are visually distinct in both ASCII art shape and color.
- [ ] Rod color wraps only rod/line characters — body, water, and fish characters remain default color.
- [ ] ANSI reset (`\e[0m`) always follows the last colored character in each row.
- [ ] Tier 10 Celestial Rod colors the arm characters in the display frame.
- [ ] EXP bar placement does not collide with Claude's text output.
- [ ] At level 50 cap, further catches still log EXP but the bar reads `MAX` and no level-up fires.
