# Catch Probability and Fish Selection

**Tags:** probability, algorithm, rarity, time-of-day, season

**Spec:** 03 — Status: IN PROGRESS

Defines the rules for rolling a catch after each conversation turn and selecting which species is caught.

## Trigger

The probability roll fires once per completed conversation turn — after Claude finishes its response. As of [[shell-catch-hook]] (Spec 12), this is implemented in a bash `Stop` hook rather than by Claude. The roll does not fire during streaming, on tool calls, or on sub-turns.

## Catch Roll

```
roll = RANDOM % 1000
if roll < 100: triggerCatch()   // flat 10% chance
```

No cooldowns. Duplicates are allowed — catching the same species multiple times is valid.

## Fish Selection Algorithm

When a catch is triggered, a species is chosen using **weighted random selection** composed of three multipliers:

```
effectiveWeight(fish) =
    BASE_WEIGHT[fish.rarity]
    × TIME_MODIFIER[period][fish.rarity]
    × SEASON_MODIFIER[season][fish.habitat]
```

### Rarity Base Weights

| Tier | Base Weight | Approximate pull rate |
|---|---|---|
| `common` | 60 | ~60% |
| `uncommon` | 25 | ~25% |
| `rare` | 12 | ~12% |
| `legendary` | 3 | ~3% |

### Time-of-Day Periods (local system clock)

| Period | Local Time |
|---|---|
| `dawn` | 05:00–08:59 |
| `day` | 09:00–16:59 |
| `dusk` | 17:00–20:59 |
| `night` | 21:00–04:59 |

Rare and legendary fish are most available at dawn, dusk, and especially deep night.

| Period | Common | Uncommon | Rare | Legendary |
|---|---|---|---|---|
| `dawn` | ×0.8 | ×1.2 | ×1.5 | ×2.0 |
| `day` | ×1.2 | ×1.0 | ×0.8 | ×0.5 |
| `dusk` | ×0.8 | ×1.2 | ×1.5 | ×1.5 |
| `night` | ×0.7 | ×1.3 | ×1.8 | ×2.5 |

### Seasons (local calendar month)

| Season | Months |
|---|---|
| `spring` | March–May |
| `summer` | June–August |
| `fall` | September–November |
| `winter` | December–February |

### Seasonal Habitat Multipliers

| Habitat | Spring | Summer | Fall | Winter |
|---|---|---|---|---|
| `freshwater` | ×1.4 | ×1.0 | ×1.2 | ×0.5 |
| `saltwater` | ×1.0 | ×1.3 | ×1.1 | ×0.8 |
| `brackish` | ×1.1 | ×1.1 | ×1.1 | ×0.7 |
| `deep-sea` | ×1.0 | ×1.0 | ×1.0 | ×1.0 |
| `tropical` | ×0.9 | ×1.5 | ×0.8 | ×0.4 |
| `arctic` | ×0.6 | ×0.3 | ×0.8 | ×1.8 |

Deep-sea fish are unaffected by season — they live below the thermocline.

### Selection

Weights are computed for all fish in the pool. A random float in `[0, totalWeight)` is drawn and an accumulated-weight scan picks the fish at the crossing point. This is a standard weighted reservoir draw.

The implementation in `scripts/gone-fishing-catch-hook.sh` uses a 30-bit `$RANDOM`-derived integer normalized into `[0, totalWeight)`, with the full `jq` selection pipeline reading `fish.json`.

## After a Catch

1. The hook writes `state.json` (caught state) for the statusline. See [[animation-system]].
2. The hook appends the catch to `catches.json`. See [[persistence-layer]].
3. The hook prints `🎣 <Name>  <ascii>  (+N EXP)` to terminal stdout.
4. Level-up is checked; if triggered, `levelUpTo` and `levelUpTier` are written into `state.json`. See [[leveling-system]].

## Related

- [[shell-catch-hook]] — bash implementation of the entire catch loop
- [[fish-database]] — rarity and habitat fields that feed the weight calculation
- [[animation-system]] — state.json fields written on catch
- [[persistence-layer]] — catches.json schema
- [[leveling-system]] — EXP award and level-up detection
