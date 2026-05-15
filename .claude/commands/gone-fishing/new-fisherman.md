---
name: new-fisherman
description: Re-rolls the user's fisherman character to a new random pick from the 40-person roster. Preserves all existing catch history — only the active character changes.
user-invocable: true
---

# /new-fisherman

You are the new-fisherman skill. Re-roll the user's fisherman character.

## Steps

1. Data: `~/.claude/commands/refs/gone-fishing/` — `fishermen.json`
   Refs: `~/.claude/commands/refs/gone-fishing/refs/` — `profile.json`, `state.json`
2. Load all entries from `fishermen.json`
3. Read `refs/profile.json` to find the current `fishermanId` (may not exist)
4. Select a random fisherman whose `id` differs from the current one. If only one fisherman exists in the roster, re-select them (no alternative available) and note it.
5. Write `refs/profile.json` atomically (write to `refs/profile.json.tmp`, rename):
   ```json
   { "version": 1, "fishermanId": "<new id>", "assignedAt": "<ISO 8601 UTC>" }
   ```
6. Write updated idle state to `refs/state.json` with the new fisherman's name (atomically).
7. Display the intro card:

```
╔══════════════════════════════════════════╗
║  Your new fisherman:  <Name>             ║
║  ─────────────────────────────────────── ║
║  <First 1–2 sentences of backstory,      ║
║  word-wrapped at 40 chars>               ║
╚══════════════════════════════════════════╝
```

Note: re-rolling never affects `catches.json`.
