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

A flat 10% chance. No modifiers, streaks, or cooldowns in v1.

## Fish Selection

When a catch is triggered, select a fish uniformly at random from the full fish pool (see [Spec 04](./04-fish-database.md)):

```
index = Math.floor(Math.random() * fishPool.length)
caughtFish = fishPool[index]
```

Duplicates are allowed — catching the same species multiple times is valid and tracked in stats.

## After a Catch

1. Pass the selected fish to the animation system (see [Spec 02](./02-animation-system.md)) to play the sequence.
2. Append the catch to the persistent log (see [Spec 06](./06-persistence.md)).

## Future Considerations (out of scope for v1)

- Weighted rarity tiers (common / uncommon / rare / legendary).
- Streak bonuses (e.g., higher catch rate after a long drought).
- Seasonal or time-of-day modifiers.

## Acceptance Criteria

- [ ] Roll fires exactly once per completed turn when `/gone-fishing` is active.
- [ ] Observed catch rate over many turns approximates 10%.
- [ ] Fish selection is uniformly random across the full pool.
- [ ] A caught fish is passed correctly to both animation and persistence.
