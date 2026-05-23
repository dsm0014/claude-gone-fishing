---
name: gone-fishing
description: Activates the ASCII fisherman overlay for this session. Catches are rolled automatically by a background hook after each turn. Run on first use to assign a random fisherman from the roster.
user-invocable: true
---

# /gone-fishing

You are the gone-fishing skill. When invoked, activate the fisherman overlay for this session.

## Directory layout (installed by scripts/install.sh)

- Data (read-only): `~/.claude/commands/refs/gone-fishing/` — contains `fish.json` and `fishermen.json`
- Refs (read/write): `~/.claude/commands/refs/gone-fishing/refs/` — contains `profile.json`, `catches.json`, `state.json`

## Activation steps

1. Read `~/.claude/commands/refs/gone-fishing/refs/profile.json` to find the current fisherman. If the file does not exist:
   - Pick a random fisherman from `~/.claude/commands/refs/gone-fishing/fishermen.json`
   - Write `profile.json` atomically (write to `profile.json.tmp`, then rename):
     ```json
     { "version": 1, "fishermanId": "<id>", "assignedAt": "<ISO 8601 UTC>" }
     ```
   - Display the intro card (see format below)
2. Load the fisherman entry from `fishermen.json` matching the saved `fishermanId`
3. Write the initial idle state to `refs/state.json` (see State file below)
4. Write `session.json` atomically (write to `session.json.tmp`, then rename):
   ```json
   { "version": 1, "fishermanId": "<id>", "fishermanName": "<Name>", "activatedAt": "<ISO 8601 UTC>" }
   ```
5. Confirm activation with one line: `🎣 Gone fishing — <Name> is on the line. Watch the status bar.`

## Intro card format (first run only)

```
╔══════════════════════════════════════════╗
║  Your fisherman:  <Name>                 ║
║  ─────────────────────────────────────── ║
║  <First 1–2 sentences of backstory,      ║
║  word-wrapped at 40 chars>               ║
╚══════════════════════════════════════════╝
```

## State file (`refs/state.json`)

The fisherman's current state is persisted here so the status bar can read it at any time. See Spec 06 for the full schema definition.

| Field | Type | Notes |
|-------|------|-------|
| `version` | number | Always `1` |
| `fishermanName` | string | Display name |
| `state` | `"idle"` \| `"caught"` | Current state |
| `catch` | object \| null | `null` when idle |
| `catch.fishId` | string | |
| `catch.common` | string | Display name |
| `catch.ascii` | string | ≤22 chars, facing left |
| `catch.color` | number | ANSI 256-color code |
| `catch.exp` | number | EXP awarded |
| `caughtAt` | string \| null | ISO 8601 UTC when caught; `null` when idle. Statusline uses this to expire the caught display after 10 seconds. |

Session liveness (`~~*~~` vs `~~~~~`) is tracked by `session.json`, not `state.json`.

Always write atomically: write to `state.json.tmp`, then rename to `state.json`.

## Error handling

- Missing `refs/` directory: create it silently
- Corrupt or missing JSON files: treat as empty, do not crash
- If `fishermen.json` or `fish.json` cannot be read: print a brief error and stop
