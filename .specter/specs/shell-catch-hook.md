# Shell Catch Hook (Stop Hook)

**Tags:** hook, bash, Stop, catch-roll, automation

**Spec:** 12 — Status: IN PROGRESS

The catch hook moves the entire per-turn catch loop out of Claude into a bash `Stop` hook. Claude no longer performs roll logic, reads `fish.json`, or writes persistence files as visible tool calls. The hook fires silently after each turn.

**Source:** `scripts/gone-fishing-catch-hook.sh`
**Deployed to:** `~/.claude/hooks/gone-fishing-catch.sh`
**Event:** `Stop` in `~/.claude/settings.json`

## Hook Flow

```
Stop event fires
  │
  ├─ Session gate: session.json absent or activatedAt > 4 h old → exit 0
  ├─ Profile gate: profile.json absent → exit 0
  │
  ├─ Catch roll: RANDOM % 1000 < 100 (10%)
  │    └─ miss: exit 0 (zero file I/O)
  │
  ├─ Compute time period (local hour) and season (local month)
  ├─ Read fish.json; compute effectiveWeight per fish; weighted random pick
  │
  ├─ Pre-catch level from current catches.json total EXP
  ├─ Write state.json atomically (caught state)
  ├─ Append catches.json atomically
  ├─ Post-catch level from new total EXP
  │    └─ If level increased: write levelUpTo + levelUpTier into state.json
  │
  └─ Print: 🎣 <Common Name>  <ascii>  (+N EXP)
```

## Key Implementation Details

**Fish selection:** Uses `jq` to compute `BASE_WEIGHT[rarity] × TIME_MOD[period][rarity] × SEASON_MOD[season][habitat]` for every fish in `fish.json`, then performs an accumulated-weight scan with a 30-bit `$RANDOM`-derived float. Matches the algorithm in [[catch-probability]] exactly.

**Level derivation:** Uses the formula `cumulative(n) = 25 * (n-1) * (n+2)` (equivalent to Spec 08's `100 + (n-1)*50` summed) to find level from total EXP. Computed for both pre-catch and post-catch totals to detect level crossings.

**No-catch path:** After the `RANDOM` roll fails, the hook exits immediately — zero file reads, zero file writes. On a ~90% no-catch turn, the hook is essentially free.

**Atomic writes:** Both `state.json` and `catches.json` are written via the `.tmp`→rename pattern. See [[persistence-layer]] for the schema of each file.

**Catch notification:** Printed to terminal stdout, not injected as a system reminder. The `UserPromptSubmit` hook (session hook) picks up the unannounced catch on the next turn by comparing `caughtAt` in `state.json` against `lastAnnouncedCatchAt` in `session.json`, and injects it into Claude's context as a `NEW CATCH` notice.

## Changes to gone-fishing.md

With this hook implemented, `gone-fishing.md` drops:
- Per-turn catch roll instructions
- Catch sequence steps (read fish.json, select fish, write state.json)
- Inline level-up notification text

What remains in `gone-fishing.md`: activation behavior, state file field table (not full schemas), and error handling sections.

## install.sh Integration

`scripts/install.sh`:
1. Copies `scripts/gone-fishing-catch-hook.sh` to `~/.claude/hooks/gone-fishing-catch.sh` and `chmod +x`.
2. Adds a `Stop` hook entry to `~/.claude/settings.json` pointing at that path.

## Related

- [[catch-probability]] — the algorithm this hook implements
- [[persistence-layer]] — state.json and catches.json schemas written by this hook
- [[animation-system]] — state.json fields that drive the statusline caught display
- [[leveling-system]] — level derivation formula and level-up fields written to state.json
- [[agentic-file-optimization]] — why the hook exists (token cost reduction, eliminating idle writes)
