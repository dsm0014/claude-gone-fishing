# Skill: /gone-fishing (System Prompt)

**Tags:** skill, command, activation, session, profile, state, atomic-write

This article documents the **actual Claude system prompt** loaded when a user invokes `/gone-fishing` — the Markdown skill definition at `.claude/commands/gone-fishing/gone-fishing.md`. It describes the exact steps Claude follows at runtime: file paths, field tables, intro card template, and error rules. For the feature-level design intent — acceptance criteria, the per-turn catch loop, and the hook lifecycle — see [[gone-fishing-command]].

## Purpose

When invoked, the skill:

1. Assigns a fisherman from [[fisherman-roster]] on first run (or reloads the saved one).
2. Writes the initial idle [[persistence-layer|state.json]].
3. Writes a fresh `session.json` to mark the session active.
4. Confirms activation with a single status line.

The catch loop itself is not part of this skill. It runs entirely in the bash `Stop` hook after Claude has already replied. See [[shell-catch-hook]].

## Directory Layout (as seen by Claude)

| Path | Mode | Contents |
|---|---|---|
| `~/.claude/commands/refs/gone-fishing/` | Read-only | `fish.json`, `fishermen.json` |
| `~/.claude/commands/refs/gone-fishing/refs/` | Read/write | `profile.json`, `catches.json`, `state.json`, `session.json` |

The data directory is populated by `scripts/install.sh`. The refs directory is created by Claude on first run if absent. See [[persistence-layer]] for full schemas.

## Activation Steps (exact runtime sequence)

1. Read `refs/profile.json`.
   - If the file does not exist: pick a random fisherman from `fishermen.json`, write `profile.json` atomically (`.tmp` then rename), display the intro card.
2. Load the matching fisherman entry from `fishermen.json` using the saved `fishermanId`.
3. Write the initial idle state to `refs/state.json` atomically.
4. Write `session.json` atomically.
5. Print one confirmation line: `🎣 Gone fishing — <Name> is on the line. Watch the status bar.`

## Intro Card Format (first run only)

Displayed immediately after character assignment:

```
╔══════════════════════════════════════════╗
║  Your fisherman:  <Name>                 ║
║  ─────────────────────────────────────── ║
║  <First 1–2 sentences of backstory,      ║
║  word-wrapped at 40 chars>               ║
╚══════════════════════════════════════════╝
```

The same card format is used by `/new-fisherman` with the header `Your new fisherman:`. See [[skill-new-fisherman]].

## state.json Fields Written by This Skill

The idle state written at activation. Full schema lives in [[persistence-layer]].

| Field | Value at activation |
|---|---|
| `version` | `1` |
| `fishermanName` | Name string from `fishermen.json` |
| `state` | `"idle"` |
| `catch` | `null` |
| `caughtAt` | `null` |

The `active` field was removed by [[agentic-file-optimization]]; session liveness is now tracked exclusively via `session.json`.

## Atomic Write Rule

Every file write uses the `.tmp`-then-rename pattern — `profile.json.tmp` → `profile.json`, `state.json.tmp` → `state.json`, etc. This matches the project-wide rule in [[persistence-layer]].

## Error Handling (exact rules from skill file)

| Condition | Behavior |
|---|---|
| `refs/` directory missing | Create it silently |
| Corrupt or missing JSON files | Treat as empty; do not crash |
| `fishermen.json` or `fish.json` unreadable | Print a brief error and stop |

## Relationship to the Session Hook

After the user has run `/gone-fishing` once, every subsequent session is auto-activated by the `UserPromptSubmit` hook (`gone-fishing-session.sh`) — the user never needs to invoke the command again. The hook performs the same profile-load and session-write steps, without displaying the intro card. See [[agentic-file-optimization]] for how this was introduced.

## Related

- [[gone-fishing-command]] — spec-level design intent, acceptance criteria, and hook lifecycle
- [[skill-fishing-stats]] — the `/fishing-stats` skill system prompt
- [[skill-new-fisherman]] — the `/new-fisherman` skill system prompt
- [[shell-catch-hook]] — the Stop hook that runs the catch roll after Claude replies
- [[persistence-layer]] — schemas for all four ref files
- [[fisherman-roster]] — character pool and intro card constraints
- [[agentic-file-optimization]] — why `state.json` no longer has an `active` field
