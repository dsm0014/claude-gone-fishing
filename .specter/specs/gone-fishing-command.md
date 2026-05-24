# /gone-fishing Command

**Tags:** command, activation, session, per-turn, hook

**Spec:** 01 — Status: IN PROGRESS

The `/gone-fishing` slash command is the entry point for the minigame. It enables the fisherman overlay for the current Claude Code session.

## Activation Behavior

When invoked:

1. Check `profile.json` for a saved fisherman. If none exists (first run), randomly select one from `fishermen.json` and save it. Display the intro card showing the character's name, type label, and backstory excerpt.
2. Write `session.json` with `activatedAt` set to the current UTC time.
3. Respond with a brief confirmation and render the character's idle frame.
4. The skill remains active for the rest of the session. There is no toggle-off.

Subsequent invocations skip character selection and reuse the saved fisherman. `/gone-fishing` can be run again to force the intro card or re-invoke if the session hook has not yet fired.

## Per-Turn Catch Loop

As of [[shell-catch-hook]] (Spec 12), the catch roll has been moved entirely out of Claude into a bash `Stop` hook. `gone-fishing.md` no longer contains per-turn roll instructions. The loop is:

1. `Stop` hook fires after Claude's response is delivered.
2. Hook checks session gate (absent or > 4 h old → exit silently).
3. Hook checks profile gate (absent → exit silently).
4. Hook rolls 10% chance. On miss: zero I/O, exits immediately.
5. On hit: selects fish from weighted pool, writes `state.json` and `catches.json`, prints catch notification to terminal.

See [[catch-probability]] for the full selection algorithm and [[shell-catch-hook]] for the hook implementation.

## Rendering

The fisherman renders anchored to the far right of the terminal using ANSI cursor positioning. The fisherman occupies the rightmost ~30 columns. On terminals narrower than 120 columns the render is skipped silently.

As of [[animation-system]] (Spec 02), all ongoing visual state is delivered through the statusline, not inline terminal frames. The statusline shows `~~*~~` while fishing is active, and `~>!<~  <fish name> <ascii>` on a catch.

## Session Persistence

`/gone-fishing` writes `session.json` on explicit invocation. The `UserPromptSubmit` hook (`gone-fishing-session.sh`) also writes `session.json` at the start of each new session, so the user only needs to run `/gone-fishing` once ever to assign a fisherman. See [[agentic-file-optimization]] for how the session hook auto-activation works.

## Acceptance Criteria

- `/gone-fishing` activates without errors.
- First run triggers character selection and shows the intro card.
- Subsequent runs skip selection and use the saved fisherman.
- Idle frame renders on the far right without overlapping Claude output.
- Catch animation (statusline) plays end-to-end when triggered.
- No visible artifacts left in the terminal after the session.

## Related

- [[animation-system]] — statusline glyph states and fish color rendering
- [[catch-probability]] — the 10% roll and weighted selection algorithm
- [[shell-catch-hook]] — the Stop hook that runs the catch roll
- [[fisherman-roster]] — character schema and frame dimensions
- [[persistence-layer]] — session.json and state.json schemas
