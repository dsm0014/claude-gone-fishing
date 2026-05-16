---
name: gone-fishing
description: Activates the ASCII fisherman overlay for this session. After each conversation turn, rolls a 10% chance to catch a fish, logging the catch and updating the statusline. Run on first use to assign a random fisherman from the roster.
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
4. Confirm activation with one line: `🎣 Gone fishing — <Name> is on the line. Watch the status bar.`

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

The fisherman's current state is persisted here so the status bar can read it at any time.

The `"active"` field marks that `/gone-fishing` has been invoked in the current session. The statusline uses it to distinguish active fishing (`~~*~~`) from a stale profile with no active session (`~~~~~`).

Idle state:
```json
{ "version": 1, "fishermanId": "<id>", "fishermanName": "<Name>", "state": "idle", "active": true, "animStartAt": 0, "catch": null }
```

Caught state (write `animStartAt` as current Unix seconds so the statusline can animate hooking→retrieving→display by elapsed time):
```json
{
  "version": 1,
  "fishermanId": "<id>",
  "fishermanName": "<Name>",
  "state": "caught",
  "active": true,
  "animStartAt": <unix_seconds>,
  "catch": { "fishId": "<id>", "common": "<common>", "ascii": "<ascii>", "color": <color>, "exp": <exp> }
}
```

Always write atomically: write to `state.json.tmp`, then rename to `state.json`.

## Per-turn catch roll

After every conversation turn completes, you MUST:

1. Roll a virtual 10% chance (~10% probability — just decide yes/no)
2. **No catch:** you MUST write idle state to `refs/state.json` (atomically). This resets any previous caught state so the statusline returns to `~~*~~`. No terminal output.
3. **Catch:** run the catch sequence below.

## Catch sequence

1. Pick a random fish from `~/.claude/commands/refs/gone-fishing/fish.json`
2. Write caught state to `refs/state.json` (atomically)
3. Append to `refs/catches.json`:
   - Read existing file (or start with `{ "version": 1, "catches": [] }` if missing/corrupt)
   - Append: `{ "fishId": "<id>", "common": "<common>", "rarity": "<rarity>", "exp": <exp>, "timestamp": "<ISO 8601 UTC>" }`
   - Write to `refs/catches.json.tmp`, rename to `refs/catches.json`
4. Print a single terminal notification:
   ```
   🎣 Fish on the line!  <Common Name>  <ascii>  (+<exp> EXP)
   ```

## Animation

The statusline script reads `state.json` on every tick and picks the frame to render:

- `state: "idle"` → idle frame
- `state: "caught"`, `elapsed < 2s` → hooking frame
- `state: "caught"`, `2s ≤ elapsed < 4s` → retrieving frame
- `state: "caught"`, `elapsed ≥ 4s` → display frame (fish held up with name and EXP)

`elapsed = now - animStartAt`. No background process is needed — the statusline polling drives the animation.

## Error handling

- Missing `refs/` directory: create it silently
- Corrupt or missing JSON files: treat as empty, do not crash
- If `fishermen.json` or `fish.json` cannot be read: print a brief error and stop
