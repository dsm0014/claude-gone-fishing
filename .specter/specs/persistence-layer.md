# Persistence Layer

**Tags:** persistence, JSON, schema, atomic-write, state

**Spec:** 06 — Status: DONE

All persistent state lives in `~/.claude/commands/refs/gone-fishing/refs/`. This directory is created on first run. Data is local-only — no cloud sync, no telemetry.

## Files

```
~/.claude/commands/refs/gone-fishing/refs/
├── catches.json   # append-only cumulative catch log
├── profile.json   # selected fisherman character
├── session.json   # active session tracking and catch announcement dedup
└── state.json     # current fisherman state for the statusline
```

## Atomic Write Rule

Every write uses the `.tmp`-then-rename pattern:

1. Serialize updated data to `<file>.tmp`.
2. `mv <file>.tmp <file>` (atomic rename).

The file is never in a partially-written state. This pattern is used for all four files.

## catches.json

Append-only log of all catches across all sessions.

```json
{
  "version": 1,
  "catches": [
    {
      "fishId": "rainbow-trout",
      "common": "Rainbow Trout",
      "rarity": "common",
      "exp": 55,
      "timestamp": "2026-05-14T10:23:00.000Z"
    }
  ]
}
```

`common`, `rarity`, and `exp` are **denormalized at catch time** — they survive edits to `fish.json`. Level and total EXP are never stored; they are always derived by summing `catches[].exp`. See [[leveling-system]].

## profile.json

Stores the user's currently selected fisherman.

```json
{
  "version": 1,
  "fishermanId": "grizzled-pete",
  "assignedAt": "2026-05-14T10:00:00.000Z"
}
```

The `fishermanId` value must match an `id` in `fishermen.json`. This file is created on first `/gone-fishing` run and updated by `/new-fisherman`. It is never reset by catch history operations.

## session.json

Tracks the active session and prevents duplicate catch announcements.

```json
{
  "version": 1,
  "fishermanId": "kodiak-karl",
  "fishermanName": "Kodiak Karl",
  "activatedAt": "2026-05-23T13:00:00Z",
  "lastAnnouncedCatchAt": "2026-05-23T13:44:52Z"
}
```

Written by the `UserPromptSubmit` hook at session start (or refreshed if `activatedAt` is more than 8 hours old), and also written by `/gone-fishing` on explicit invocation. `lastAnnouncedCatchAt` is updated by the hook each time it injects a catch announcement, preventing the same catch from being announced twice across turns.

The statusline and catch hook both gate on `activatedAt`: the statusline uses an 8-hour window, the catch hook uses a 4-hour window.

## state.json

Stores the fisherman's real-time state for the statusline script.

**Idle state:**
```json
{
  "version": 1,
  "fishermanName": "Grizzled Pete",
  "state": "idle",
  "catch": null
}
```

**Caught state:**
```json
{
  "version": 1,
  "fishermanName": "Grizzled Pete",
  "state": "caught",
  "caughtAt": "2026-05-23T13:44:52Z",
  "catch": { "fishId": "rainbow-trout", "common": "Rainbow Trout", "ascii": "><(((º>", "color": 75, "exp": 30 }
}
```

`caughtAt` drives the 120-second display window in the statusline. The `active` field was removed as of [[agentic-file-optimization]] — session state is determined solely from `session.json`. Level-up detection adds `levelUpTo` and `levelUpTier` fields to the caught state; the statusline surfaces these.

## Read/Write Rules

- **Write:** atomic `.tmp` → rename for all four files.
- **Read:** parse JSON; return empty/default if file does not exist.
- **Schema mismatch:** if `version` is missing or higher than current, log a warning and treat as empty — do not overwrite.
- **Corruption:** if the file is not valid JSON, log a warning and treat as empty — do not overwrite.

## Related

- [[shell-catch-hook]] — primary writer of `state.json` and `catches.json`
- [[agentic-file-optimization]] — removal of idle-reset writes, introduction of session.json
- [[leveling-system]] — derives level by summing `catches[].exp`
- [[fishing-stats-command]] — reads `catches.json` and `profile.json`
- [[animation-system]] — reads `state.json` and `session.json`
