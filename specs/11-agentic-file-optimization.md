# Spec 11 — Agentic File Optimization

**Status:** `COMPLETE`
**Depends on:** All existing specs (cross-cutting concern)

## Goal

Reduce per-conversation and per-invocation token overhead without losing information Claude needs to operate correctly. The primary lever is what gets loaded automatically (CLAUDE.md `@`-imports, always in context) versus on demand (skill files, loaded at invocation) versus at runtime (JSON data files, read via tool calls).

---

## Token Cost Audit

### Per-conversation (always loaded via CLAUDE.md `@`-imports)

| File | Size | Verdict |
|------|------|---------|
| `CLAUDE.md` | ~0.3K | Keep; trim inline status notes |
| `.claude/ARCHITECTURE.md` | ~3.6K | Trim; remove "Current state" blocks |
| `.claude/glossary.md` | ~1.4K | Partially inline into CLAUDE.md; remove the file |

### Per-invocation (loaded when a skill is activated)

| File | Size | Verdict |
|------|------|---------|
| `gone-fishing.md` | ~4.5K | Trim state file schema |
| `fishing-stats.md` | ~2.0K | Keep as-is |
| `new-fisherman.md` | ~1.6K | Keep as-is |

### On-demand reads (explicit tool calls at runtime — unavoidable)

| File | Size | Notes |
|------|------|-------|
| `fish.json` | ~35K | Read by skills; no optimization opportunity |
| `fishermen.json` | ~6K | Read by skills; no optimization opportunity |

---

## Proposed Changes

### 1. ARCHITECTURE.md — Remove inline implementation status blocks

Several component entries contain "Current state: Not yet implemented" paragraphs (Animation frames, Leveling system). These:
- Rot as work progresses and must be manually kept in sync
- Are redundant with `specs/00-index.md`, which is the authoritative status tracker
- Add ~300 tokens to every conversation regardless of whether that context is needed

**Action:** Delete "Current state" paragraphs from `ARCHITECTURE.md`. The specs are the source of truth for what is and isn't implemented.

---

### 2. glossary.md — Inline non-obvious terms, remove the file

The glossary is `@`-imported unconditionally, adding ~350 tokens per conversation. Most terms are either obvious from context or defined formally in specs. Only two carry non-obvious implementation detail worth preserving:

- **Atomic write** — the `.tmp`-then-rename pattern (non-obvious; worth keeping near the persistence constraints)
- **Skill definition** — clarifies that `*.md` files in `~/.claude/commands/` are system prompts, not documentation

**Action:**
1. Add a "Conventions" section to `CLAUDE.md` with one-line definitions of "Atomic write" and "Skill definition"
2. Delete `glossary.md` and remove its `@`-import from `CLAUDE.md`

The remaining glossary terms (Catch, EXP, Rarity, Frame state, Rod tier, Statusline, Catch roll) are sufficiently defined by context and specs.

---

### 3. CLAUDE.md — Add an agentic conventions section

Several conventions are currently re-derived each session because they aren't written down anywhere Claude loads automatically. Making them explicit reduces correction loops.

Add a **Conventions** section covering:

- Skill files live in `.claude/commands/gone-fishing/` (source). They are deployed to `~/.claude/commands/` via `scripts/install.sh`. Never write skill or data files directly to `~/.claude/`.
- New specs go in `specs/` numbered sequentially. Always update `specs/00-index.md` when adding a spec.
- Changes to `fish.json` or `fishermen.json` require a reinstall (`scripts/install.sh`) to take effect at the installed path.
- Worktrees go in `../claude-gone-fishing-<name>/` (sibling to the main repo). Use them for parallel branch work; avoid checking out multiple branches in the same working tree.
- Persistent data (catches, profile, state) lives in `~/.claude/commands/refs/gone-fishing/refs/`. It is never committed to the repo.

---

### 4. gone-fishing.md — Slim the state file schema

The full idle and caught JSON examples in `gone-fishing.md` duplicate what Spec 06 already defines formally. They add ~150 tokens per skill invocation.

**Action:** Replace the two full JSON blocks with a compact field table listing name, type, and any non-obvious constraint. Reference Spec 06 for the full schema. Keep the animation timing table (elapsed thresholds) since that is runtime behavior not covered elsewhere.

---

### 5. settings.json — Expand Read allowlist

The current allowlist generates prompts for read operations on the data directory. The `Bash` mv allowlist is partially addressed by item 6 (eliminating no-catch writes), but the Read side still needs broadening.

**Action:** Add a broad `Read` allow for `~/.claude/commands/refs/gone-fishing/**` so skill file reads never prompt. The mv permission is only needed on actual catches (~10% of turns) — keep the existing entry but no longer treat it as the primary friction point.

---

### 6. Per-turn state writes — eliminate idle resets, push expiry into statusline *(partially complete)*

**The problem:** `gone-fishing.md` currently requires Claude to write `state.json` on every conversation turn — both on catch (correct) and on no-catch (wasteful). No-catch turns are ~90% of all turns. Each one triggers a silent `mv` permission call with zero user-visible effect. Writing `active: true` every turn is also the only reason the active-session glyph (`~~*~~`) works — without it, the flag goes stale.

**Root cause:** State expiry (caught → idle after the animation plays) is driven by Claude writes rather than by the statusline itself, even though the statusline already computes `elapsed = now - animStartAt` and has all the information it needs.

**Proposed changes:**

**a. Statusline handles caught-state expiry**

The statusline already branches on elapsed time for animation frames. Extend it: if `state == "caught"` and `elapsed >= 10` (seconds), render the idle frame without waiting for Claude to write anything. This makes the statusline self-contained for all state transitions except the initial catch event.

**b. Claude: no write on no-catch**

Remove the "No catch: write idle state" step from the per-turn section of `gone-fishing.md`. Claude writes `state.json` only when there is an actual catch. The statusline's elapsed-based expiry handles the visual reset.

**c. Replace per-turn `active` flag with one-time session write**

The `active: true` field exists solely to show `~~*~~` vs `~~~~~` in the statusline. Rather than re-asserting it every turn, write a separate `session.json` exactly once at `/gone-fishing` invocation:

```json
{ "version": 1, "fishermanId": "<id>", "fishermanName": "<Name>", "activatedAt": "<ISO 8601 UTC>" }
```

The statusline shows `~~*~~` if `session.json` exists and `activatedAt` is within the last 8 hours; `~~~~~` otherwise. Drop the `active` field from `state.json` entirely.

**Impact:**
- No-catch turns (90%): zero file I/O, no permission prompts
- Catch turns (10%): one atomic write to `state.json` + one append to `catches.json` — same as today
- `/gone-fishing` activation: one additional write to `session.json` — negligible

**What's done (branch `enhance-agentic-files`):** Sub-item 6c is complete — the statusline reads `session.json.activatedAt` for the active-glyph decision and no longer depends on the `active` field in `state.json`. Sub-items 6a and 6b remain open: `gone-fishing.md` still instructs an idle write on every no-catch turn, and the statusline does not yet do elapsed-based expiry of the caught state.

---

### 7. Auto-activate fishing via `UserPromptSubmit` hook *(complete)*

**The problem:** After running `/gone-fishing` once to assign a fisherman, the user must re-run it at the start of every new session. There is no mechanism to persist the "fishing is active" intent across sessions without user action.

**Proposed change:**

Install a `UserPromptSubmit` hook (`~/.claude/hooks/gone-fishing-session.sh`) that fires before every user message. The hook:

1. Exits silently if `profile.json` does not exist (user has never fished)
2. Reads `session.json`; if `activatedAt` is less than 8 hours old, outputs the activation notice and exits
3. Otherwise, reads `fishermanId` from `profile.json`, resolves the name from `fishermen.json`, writes a fresh `session.json`, and outputs the activation notice

The activation notice injected into the conversation:
```
[gone-fishing] <Name> is on the line. Apply the per-turn catch roll after responding.
```

Claude Code injects this as context before processing the user's message, so Claude knows fishing is active and applies the catch roll without the user typing `/gone-fishing`.

**Interaction with item 6:**

The hook is the primary writer of `session.json`. `/gone-fishing` also writes `session.json` when invoked explicitly (first run, or to show the intro card again). The statusline reads `session.json.activatedAt` to determine the `~~*~~` vs `~~~~~` glyph — the same file the hook writes, so the statusline shows active from the first message of every session.

**Impact:**
- First ever run: user runs `/gone-fishing` once to get a fisherman assigned and see the intro card
- Every subsequent session: hook fires automatically, writes `session.json`, activates fishing invisibly
- `/gone-fishing` remains invocable if the user wants to force the intro card or re-assign a fisherman
- Token cost: ~15 tokens per message (the injected activation notice); acceptable given it replaces the 150-token idle write step

**Install changes:**
- `scripts/install.sh` copies `scripts/gone-fishing-session-hook.sh` to `~/.claude/hooks/gone-fishing-session.sh`
- `install.sh` adds a `UserPromptSubmit` hook entry to `~/.claude/settings.json` pointing at that script

**What's done (branch `enhance-agentic-files`):** All of item 7 is implemented. `scripts/gone-fishing-session-hook.sh` exists and handles all cases (no profile → silent exit; session < 8 h → reuse and inject; otherwise → write fresh `session.json` and inject). `scripts/install.sh` deploys the hook and writes the `UserPromptSubmit` entry to `~/.claude/settings.json`.

---

## Acceptance Criteria

- [x] ARCHITECTURE.md contains no "Current state" paragraphs; spec statuses are authoritative.
- [x] `glossary.md` is deleted; its `@`-import is removed from `CLAUDE.md`.
- [x] `CLAUDE.md` has a Conventions section covering the five points above.
- [x] `gone-fishing.md` state file section uses a field table, not full JSON examples.
- [x] `settings.json` allows Read on the full gone-fishing data directory without prompting.
- [x] Total size of always-loaded context (CLAUDE.md + @-imports) is reduced by at least 30% (34.3%; 6,012 → 3,949 bytes).
- [x] `gone-fishing.md` per-turn section has no idle write step; no-catch turns produce zero file I/O.
- [x] `state.json` schema drops the `active` field; `session.json` is written once at activation.
- [x] Statusline renders idle frame when `state == "caught"` and `elapsed >= 10s` without a file read/write.
- [x] Statusline uses `activatedAt` timestamp from `session.json` for active-glyph logic.
- [x] `/gone-fishing` writes `session.json` on explicit invocation.
- [x] `~/.claude/hooks/gone-fishing-session.sh` installed by `scripts/install.sh`; fires on every `UserPromptSubmit`.
- [x] Hook exits silently when `profile.json` is absent (user has never fished).
- [x] Hook writes `session.json` on session start and injects `[gone-fishing] <Name> is on the line...` notice.
- [x] Hook reuses existing `session.json` if `activatedAt` is less than 8 hours old.
- [x] `settings.json` has a `UserPromptSubmit` hook entry pointing at the hook script after install.
