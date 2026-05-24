# Skill: /new-fisherman (System Prompt)

**Tags:** skill, command, re-roll, character, profile, roster, non-destructive

This article documents the **actual Claude system prompt** loaded when a user invokes `/new-fisherman` — the Markdown skill definition at `.claude/commands/gone-fishing/new-fisherman.md`. It specifies the exact runtime steps, the "differs from current" selection logic, the files touched, and the intro card format. There is no separate spec article for this command; [[gone-fishing-command]] and [[fisherman-roster]] cover the broader design context.

## Purpose

`/new-fisherman` replaces the user's active fisherman character with a randomly chosen different entry from `fishermen.json`. Catch history (`catches.json`) is never touched — all EXP, level progress, and past catches are fully preserved. Only `profile.json` and `state.json` are updated.

## Input and Output Files

| File | Path | Operation |
|---|---|---|
| `fishermen.json` | `~/.claude/commands/refs/gone-fishing/fishermen.json` | Read; source of all candidates |
| `profile.json` | `refs/profile.json` | Read current `fishermanId`; overwritten with new selection |
| `state.json` | `refs/state.json` | Overwritten with idle state carrying new fisherman's name |
| `catches.json` | `refs/catches.json` | Not touched |

See [[persistence-layer]] for full schemas and the atomic write rule.

## Step-by-Step Execution (exact runtime sequence)

1. Load all entries from `fishermen.json`.
2. Read `refs/profile.json` to find the current `fishermanId`. (File may not exist on first run.)
3. Select a random fisherman whose `id` differs from the current one.
   - Edge case: if only one entry exists in `fishermen.json`, re-select them.
4. Write `refs/profile.json` atomically (`.tmp` then rename).
5. Write updated idle `state.json` atomically, using the new fisherman's name.
6. Display the intro card.

The "differs from current" guarantee means the user always gets a genuinely new character as long as more than one is in the roster.

## Intro Card Format

```
╔══════════════════════════════════════════╗
║  Your new fisherman:  <Name>             ║
║  ─────────────────────────────────────── ║
║  <First 1–2 sentences of backstory,      ║
║  word-wrapped at 40 chars>               ║
╚══════════════════════════════════════════╝
```

This is identical in structure to the first-run intro card shown by `/gone-fishing` (see [[skill-gone-fishing]]), with the header changed from `Your fisherman:` to `Your new fisherman:`. Backstory text comes from the `backstory` field in `fishermen.json`; word-wrap target is 40 inner characters. See [[fisherman-roster]] for backstory length and voice constraints.

## What Is and Is Not Affected

| Data | Affected? |
|---|---|
| Active fisherman name and backstory | Yes — replaced |
| `profile.json` | Yes — overwritten |
| `state.json` (fisherman name field) | Yes — updated |
| `catches.json` | No — untouched |
| EXP total and level | No — derived at runtime from `catches.json` |
| Session activity (`session.json`) | No — not written by this skill |

This is the key design guarantee of the command: a re-roll is purely cosmetic from the persistence layer's perspective. The next `/fishing-stats` invocation will show the new character's name and backstory over the same catch history.

## Atomic Write Rule

Both `profile.json` and `state.json` are written using the `.tmp`-then-rename pattern, consistent with the project-wide rule in [[persistence-layer]].

## Related

- [[skill-gone-fishing]] — assigns the first fisherman; shares the intro card structure
- [[skill-fishing-stats]] — the command that displays the currently selected fisherman's stats
- [[fisherman-roster]] — the 40-entry character pool; backstory and frame constraints
- [[persistence-layer]] — `profile.json` and `state.json` schemas; atomic write rule
- [[gone-fishing-command]] — broader session and activation design context
