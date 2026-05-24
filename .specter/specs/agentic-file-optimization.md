# Agentic File Optimization

**Tags:** optimization, hooks, token-cost, session, UserPromptSubmit

**Spec:** 11 — Status: partially implemented (items 1–5, 7 done; items 6a/6b in progress)

Cross-cutting optimization across all skill files. The goal is to reduce per-conversation and per-invocation token overhead without losing information Claude needs to operate correctly.

## What Changed

### Context Size Reduction

- **ARCHITECTURE.md:** "Current state" implementation-status blocks removed. Spec statuses (`specs/00-index.md`) are the authoritative tracker.
- **glossary.md:** Deleted; its `@`-import removed from `CLAUDE.md`. Two non-obvious terms (atomic write, skill definition) inlined as one-liners into `CLAUDE.md`.
- **CLAUDE.md:** Added a Conventions section covering: source vs deployed paths, spec numbering convention, install requirement for `fish.json`/`fishermen.json` changes, worktree location convention, persistent data location.
- **gone-fishing.md:** State file section replaced full JSON examples with a compact field table. Reduces ~150 tokens per skill invocation.

Net result: always-loaded context (CLAUDE.md + `@`-imports) reduced by 34.3% — from 6,012 to 3,949 bytes.

### Permissions (settings.json)

Added a broad `Read` allowlist for `~/.claude/commands/refs/gone-fishing/**` so data file reads never prompt. The `Bash(mv ...)` entry covers only catch turns (10%) rather than all turns.

### Idle Write Elimination (partially complete)

**The problem:** `gone-fishing.md` previously required Claude to write `state.json` on every turn — both on catch (necessary) and on no-catch (wasteful at 90% of turns).

**Completed:**
- `state.json` no longer has an `active` field. Session activity is determined from `session.json`.
- The statusline handles caught→idle transitions autonomously via the 120-second `caughtAt` elapsed check — no Claude write needed.
- `session.json` is written once per session by the `UserPromptSubmit` hook, not re-written on every turn.

**Still open:**
- `gone-fishing.md` still contains a no-catch idle write step.
- The statusline does not yet do elapsed-based expiry (this is implemented in `install.sh`'s inlined statusline script, contradicting the spec status).

### UserPromptSubmit Session Hook (complete)

`scripts/gone-fishing-session-hook.sh` fires before every user message:
1. If `profile.json` absent: exits silently.
2. If `session.json` exists and `activatedAt` is within 8 hours: injects `[gone-fishing] <Name> is on the line.` and exits. Also checks for an unannounced catch (compares `state.json.caughtAt` against `session.json.lastAnnouncedCatchAt`) and injects a `NEW CATCH` notice if found.
3. Otherwise: reads `fishermanId` from `profile.json`, resolves name from `fishermen.json`, writes a fresh `session.json`, injects activation notice.

This means the user only needs to run `/gone-fishing` once ever. Every subsequent session activates automatically. Token cost: ~15 tokens per message for the injected notice — far less than the 150-token idle write it replaced.

### Stop Hook (catch moved out of Claude)

The per-turn catch roll was moved to a bash `Stop` hook. See [[shell-catch-hook]] for full details. This eliminated all per-turn tool calls from the catch loop and removed those instructions from `gone-fishing.md`.

## Install Changes

`scripts/install.sh`:
- Deploys `gone-fishing-session-hook.sh` to `~/.claude/hooks/gone-fishing-session.sh`.
- Deploys `gone-fishing-catch-hook.sh` to `~/.claude/hooks/gone-fishing-catch.sh`.
- Writes `UserPromptSubmit` and `Stop` hook entries to `~/.claude/settings.json`.
- Writes `Read`/`Write`/`Bash(mv)` permission allowlist entries.

## Related

- [[shell-catch-hook]] — the Stop hook that replaces Claude's per-turn catch roll
- [[persistence-layer]] — session.json schema; the idle-reset elimination relies on session.json
- [[animation-system]] — statusline elapsed-based expiry that makes idle writes unnecessary
- [[gone-fishing-command]] — activation behavior updated by this spec
