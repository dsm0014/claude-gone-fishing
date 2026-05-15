# Spec 03 — Catch Probability

**Status:** `TODO`
**Depends on:** [04 Fish Database](./04-fish-database.md), [06 Persistence Layer](./06-persistence.md)

---

## Purpose

Defines the rules for rolling a catch after each conversation turn and selecting which fish is caught.

## Trigger

The probability roll fires **once per completed conversation turn** — after Claude finishes its response, before the next user prompt. It does not fire:
- During streaming (mid-response).
- On tool calls or internal sub-turns.
- Before the user has sent their first message in a session.

## Roll Logic

```
catchRoll = Math.random()   // [0, 1)
if catchRoll < 0.10:
    triggerCatch()
```

A flat 10% chance. No cooldowns.

## Fish Selection

When a catch is triggered, select a fish using **weighted random selection** driven by three stacked factors: the fish's rarity tier, the current time of day, and the current season.

### Rarity Tier Base Weights

Each fish in the pool has a `rarity` field (see [Spec 04](./04-fish-database.md)). Base weights before any modifiers:

| Tier | Base Weight | Baseline Pull Rate |
|------|-------------|-------------------|
| `common` | 60 | ~60% |
| `uncommon` | 25 | ~25% |
| `rare` | 12 | ~12% |
| `legendary` | 3 | ~3% |

### Time-of-Day Periods

Derived from the **local system clock** at the moment the catch roll fires — not UTC.

| Period | Local Time Range |
|--------|-----------------|
| `dawn` | 05:00–08:59 |
| `day` | 09:00–16:59 |
| `dusk` | 17:00–20:59 |
| `night` | 21:00–04:59 |

### Time-of-Day Multipliers

Applied to each fish's base rarity weight. Rare and legendary fish are most available at the edges of day — especially deep night.

| Period | Common | Uncommon | Rare | Legendary |
|--------|--------|----------|------|-----------|
| `dawn` | ×0.8 | ×1.2 | ×1.5 | ×2.0 |
| `day` | ×1.2 | ×1.0 | ×0.8 | ×0.5 |
| `dusk` | ×0.8 | ×1.2 | ×1.5 | ×1.5 |
| `night` | ×0.7 | ×1.3 | ×1.8 | ×2.5 |

### Seasons

Derived from the **local calendar month**.

| Season | Months |
|--------|--------|
| `spring` | March–May |
| `summer` | June–August |
| `fall` | September–November |
| `winter` | December–February |

### Seasonal Multipliers by Habitat

Applied to each fish's effective weight based on its `habitat` field (see [Spec 04](./04-fish-database.md)). Deep-sea fish are unaffected by season — they live below the thermocline.

| Habitat | Spring | Summer | Fall | Winter |
|---------|--------|--------|------|--------|
| `freshwater` | ×1.4 | ×1.0 | ×1.2 | ×0.5 |
| `saltwater` | ×1.0 | ×1.3 | ×1.1 | ×0.8 |
| `brackish` | ×1.1 | ×1.1 | ×1.1 | ×0.7 |
| `deep-sea` | ×1.0 | ×1.0 | ×1.0 | ×1.0 |
| `tropical` | ×0.9 | ×1.5 | ×0.8 | ×0.4 |
| `arctic` | ×0.6 | ×0.3 | ×0.8 | ×1.8 |

### Selection Algorithm

```
function selectFish(fishPool, localHour, localMonth):
    period = getTimePeriod(localHour)   // dawn | day | dusk | night
    season = getSeason(localMonth)       // spring | summer | fall | winter

    weights = fishPool.map(fish =>
        BASE_WEIGHT[fish.rarity]
        * TIME_MODIFIER[period][fish.rarity]
        * SEASON_MODIFIER[season][fish.habitat]
    )

    totalWeight = sum(weights)
    roll = Math.random() * totalWeight

    accumulator = 0
    for i in range(fishPool.length):
        accumulator += weights[i]
        if roll < accumulator:
            return fishPool[i]
```

Duplicates are allowed — catching the same species multiple times is valid and tracked in stats.

## After a Catch

1. Pass the selected fish to the animation system (see [Spec 02](./02-animation-system.md)) to play the sequence.
2. Append the catch to the persistent log (see [Spec 06](./06-persistence.md)).

## Acceptance Criteria

- [ ] Roll fires exactly once per completed turn when `/gone-fishing` is active.
- [ ] Observed catch rate over many turns approximates 10%.
- [ ] Fish selection uses weighted random, not uniform random.
- [ ] Unmodified rarity pull rates approximate 60 / 25 / 12 / 3%.
- [ ] Time-of-day period is derived from local system clock, not UTC.
- [ ] Season is derived from local calendar month.
- [ ] Effective weight correctly composes rarity × time × season multipliers.
- [ ] A caught fish is passed correctly to both animation and persistence.
