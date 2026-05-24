# Leveling System

**Tags:** leveling, EXP, rod-tier, progression, statusline

**Spec:** 08 — Status: TODO (spec written, not yet fully implemented)

The leveling system tracks the fisherman's cumulative EXP across all catches and expresses progression through rod tier colors in the statusline and an EXP bar in `/fishing-stats`.

## EXP Per Catch

Each fish in `fish.json` has a fixed `exp` value assigned at authoring time. EXP is awarded immediately when the catch is logged. Ranges by tier:

| Tier | Examples | EXP range |
|---|---|---|
| Common freshwater | Bluegill, Perch, Sunfish | 15–30 |
| Common saltwater | Mackerel, Herring, Flounder | 25–45 |
| Sport/game fish | Largemouth Bass, Rainbow Trout, Mahi-Mahi | 40–75 |
| Rare/trophy | Tarpon, Giant Trevally, Arapaima | 70–120 |
| Deep sea/exotic | Anglerfish, Viperfish, Oarfish | 100–175 |
| Legendary | Coelacanth, Paddlefish, Taimen | 175–250 |

## Level Thresholds

50 total levels. Linear progression:

```
threshold(n) = 100 + (n - 1) * 50
cumulative(n) = 25 * (n - 1) * (n + 2)
```

At typical usage (~5 catches/day, ~60 EXP average = 300 EXP/day):
- Level 10: ~10 days
- Level 20: ~38 days
- Level 50: ~222 days

Level 50 is the cap. Further catches still log EXP, but the bar reads `MAX` and no level-up fires.

## Level Derivation

Level is **always derived at runtime** from `catches.json` — never stored directly:

```
totalExp = sum of all catches[].exp
currentLevel = highest n where cumulative(n) <= totalExp
```

This means retroactive EXP changes or fish rebalancing self-correct automatically. See [[persistence-layer]] for why EXP fields are denormalized at catch time.

## Rod Tier Colors

Every 5 levels the lure color upgrades. The tier ANSI color applies to both the lure glyph `*` in `~~*~~` and the level label `Lv.NN` in the statusline — they form a matched visual pair.

| Levels | Tier | Name | ANSI |
|---|---|---|---|
| 1–4 | 1 | Willow Branch | none (default) |
| 5–9 | 2 | Bamboo Rod | `\e[33m` dim yellow |
| 10–14 | 3 | Fiberglass Rod | `\e[37m` light gray |
| 15–19 | 4 | Spinning Rod | `\e[36m` cyan |
| 20–24 | 5 | Baitcaster | `\e[92m` bright green |
| 25–29 | 6 | Carbon Fiber | `\e[1;90m` bold dark gray |
| 30–34 | 7 | Fly Rod | `\e[94m` bright blue |
| 35–39 | 8 | Surf Rod | `\e[96m` bright cyan |
| 40–44 | 9 | Gilded Rod | `\e[1;33m` bold gold |
| 45–50 | 10 | Celestial Rod | `\e[1;95m` bold magenta |

```
rodTier = floor((currentLevel - 1) / 5) + 1   // clamps to 10 at level 50
```

No tier color is applied in the inactive state (`~~~~~`).

## EXP Bar (in /fishing-stats)

```
Lv.12  ████████████░░░░░░░░  800 / 1100 XP
```

- Label `Lv.NN` in current tier color, right-padded to 6 chars.
- 20-character block: filled `█` at `floor(20 × expIntoLevel / expNeeded)`, rest `░`.
- At level 50: full bar, fraction replaced with `MAX`.

## Level-Up Notification

When a catch pushes the fisherman to a new level, the catch hook writes `levelUpTo` and `levelUpTier` into `state.json`. The statusline (or session hook on the next turn) surfaces the level-up. No inline conversation text is emitted by the hook.

Prior to [[shell-catch-hook]] (Spec 12), level-up notifications were emitted inline by Claude. In the current architecture they are surfaced via the statusline only.

## Statusline Derivation

`statusline-command.sh` reads `catches.json` on every tick to derive `totalExp`, `level`, and `tier`, then applies the tier ANSI color to `*` and `Lv.NN`. A missing `catches.json` defaults to level 1, tier 1 (no color) without error.

## Related

- [[persistence-layer]] — `catches.json` is the sole source of truth for EXP
- [[fish-database]] — `exp` field on every species entry
- [[animation-system]] — tier color applied to `*` and `Lv.NN` in the statusline
- [[shell-catch-hook]] — computes level-up and writes `levelUpTo`/`levelUpTier` to `state.json`
- [[fishing-stats-command]] — renders the EXP bar
