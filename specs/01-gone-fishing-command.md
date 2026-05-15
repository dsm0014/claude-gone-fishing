# Spec 01 — /gone-fishing Command

**Status:** `TODO`
**Depends on:** [02 Animation System](./02-animation-system.md), [03 Catch Probability](./03-catch-probability.md), [07 Fisherman Roster](./07-fisherman-roster.md)

---

## Purpose

The `/gone-fishing` slash command enables the ASCII art fisherman overlay for the current Claude Code session. Once enabled, the fisherman persists for the duration of the session and reacts to conversation turns.

## Behavior

### Activation
- User invokes `/gone-fishing` at any point during a session.
- **First run only:** Check `refs/profile.json` for a saved fisherman. If none exists, randomly select one from the roster and display the intro card (see [Spec 07](./07-fisherman-roster.md)).
- Claude responds with a brief confirmation (e.g., `🎣 Gone fishing...`) and renders the selected character's idle frame.
- The skill remains active for the rest of the session; there is no toggle-off in this version.

### Per-Turn Hook
After every conversation turn completes:
1. Roll a 10% chance of catching a fish (see [Spec 03](./03-catch-probability.md)).
2. If no catch: redraw the idle frame.
3. If catch: run the hook → retrieve → display animation sequence (see [Spec 02](./02-animation-system.md)), then write the result to the catch log (see [Spec 06](./06-persistence.md)).

### Rendering Position
- The fisherman renders anchored to the **far right** of the terminal.
- Use ANSI cursor positioning to avoid overwriting Claude's text output.
- Minimum terminal width assumed: 120 columns. The fisherman occupies the rightmost ~30 columns.
- On terminals narrower than 120 columns, skip rendering and silently no-op.

## Skill File

**Path:** `~/.claude/skills/gone-fishing/gone-fishing.md`

The skill definition must describe:
- How to render each animation frame using `process.stdout.write` or equivalent ANSI output.
- The per-turn trigger logic.
- Where to find the fish database and catch log.

## Acceptance Criteria

- [ ] `/gone-fishing` activates without errors.
- [ ] First run triggers character selection and shows the intro card before activating.
- [ ] Subsequent runs skip character selection and use the saved fisherman.
- [ ] Idle frame renders on the far right without overlapping Claude output.
- [ ] Per-turn hook fires after every response.
- [ ] Catch animation plays end-to-end when triggered.
- [ ] No visible artifacts left in the terminal after the session.
