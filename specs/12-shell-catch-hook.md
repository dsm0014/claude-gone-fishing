# Spec 12 — Shell Catch Hook

**Status:** IN PROGRESS

**Depends on:** [Spec 03 — Catch Probability](./03-catch-probability.md), [Spec 06 — Persistence Layer](./06-persistence.md), [Spec 08 — Leveling System](./08-leveling-system.md)

## Purpose

Move the per-turn catch roll entirely out of Claude into a bash `Stop` hook. Claude currently performs the roll as visible tool calls (reading `fish.json`, writing `state.json` and `catches.json`). The hook performs those operations silently after each turn — invisible to the model. `gone-fishing.md` drops the per-turn catch roll instructions entirely.

## Behavior

- **Hook file:** `scripts/gone-fishing-catch-hook.sh` (source), deployed by `install.sh` to `~/.claude/hooks/gone-fishing-catch.sh`
- **Registration:** `Stop` event in `~/.claude/settings.json` — fires once after Claude's full response is delivered
- **Session gate:** On entry, read `~/.claude/commands/refs/gone-fishing/refs/session.json`. If the file is absent or `activatedAt` is more than 4 hours old (14400 seconds), exit 0 silently
- **Profile gate:** If `profile.json` is absent, exit 0 silently (user has never fished)
- **Catch roll:** Generate a random integer in [0, 999] via `$RANDOM % 1000`; proceed to fish selection only if the value is less than 100 (flat 10% chance)
- **Fish selection:** Read `fish.json`; compute each fish's effective weight as `BASE_WEIGHT[rarity] * TIME_MOD[period][rarity] * SEASON_MOD[season][habitat]` using local hour and month; pick by accumulated-weight scan, matching the algorithm in Spec 03 exactly
- **state.json write:** On catch, write atomically (`state.json.tmp` → rename): `{ "version": 1, "fishermanName", "state": "caught", "caughtAt": "<ISO 8601 UTC>", "catch": { "fishId", "common", "ascii", "color", "exp" } }`
- **catches.json write:** Read existing file (default `{ "version": 1, "catches": [] }` if absent/corrupt); append `{ "fishId", "common", "rarity", "exp", "timestamp" }`; write atomically (`catches.json.tmp` → rename)
- **Catch notification:** Print one line to stdout: `🎣 <Common Name>  <ascii>  (+<exp> EXP)`
- **Level-up:** Compute `prevLevel` from pre-append EXP and `newLevel` from post-append EXP using Spec 08 formula. If `newLevel > prevLevel`, write `levelUpTo` and `levelUpTier` fields into `state.json`. The statusline script surfaces the level-up; no inline text is emitted by the hook
- **No-catch turn:** Hook exits 0 immediately after the roll fails — zero file I/O
- **install.sh changes:** Deploy `gone-fishing-catch-hook.sh` to `~/.claude/hooks/`; `chmod +x`; add a `Stop` hook entry to `~/.claude/settings.json`
- **gone-fishing.md changes:** Remove the per-turn catch roll instructions, catch sequence steps, and inline level-up notification text; retain activation, state file schema, and error handling sections

## Acceptance Criteria

- [ ] `scripts/gone-fishing-catch-hook.sh` exists in the repo and is deployed by `install.sh` to `~/.claude/hooks/gone-fishing-catch.sh`
- [ ] `~/.claude/settings.json` contains a `Stop` hook entry pointing at `gone-fishing-catch.sh` after install
- [ ] Hook exits silently (no output, no file I/O) when `session.json` is absent or `activatedAt` is older than 4 hours
- [ ] Hook exits silently when `profile.json` is absent
- [ ] Observed catch rate over 50+ turns approximates 10%
- [ ] Fish selection applies rarity × time-of-day × season weights per Spec 03
- [ ] `state.json` is written atomically with correct fields on a catch turn
- [ ] `catches.json` is appended atomically with correct fields on a catch turn
- [ ] No-catch turns produce zero file I/O
- [ ] Catch notification prints to terminal stdout; no Claude system-reminder is emitted
- [ ] Level-up writes `levelUpTo` and `levelUpTier` to `state.json`; statusline surfaces it; no inline conversation text
- [ ] `gone-fishing.md` contains no per-turn catch roll instructions or inline level-up notification text
