# Spec 11 — Agentic File Optimization

**Status:** `IN PROGRESS`
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

### 5. settings.json — Expand permission allowlist

The current allowlist is minimal and generates prompts for common read operations on the data and refs directories. Transcript review is needed to identify the most frequent recurring prompts.

**Action:** After reviewing recent permission prompts, add broad `Read` allows for the data directory and expand the `Bash` allow to cover common atomic write patterns without listing each file individually.

---

## Acceptance Criteria

- [ ] ARCHITECTURE.md contains no "Current state" paragraphs; spec statuses are authoritative.
- [ ] `glossary.md` is deleted; its `@`-import is removed from `CLAUDE.md`.
- [ ] `CLAUDE.md` has a Conventions section covering the five points above.
- [ ] `gone-fishing.md` state file section uses a field table, not full JSON examples.
- [ ] `settings.json` allows Read on the full gone-fishing data directory without prompting.
- [ ] Total size of always-loaded context (CLAUDE.md + @-imports) is reduced by at least 30%.
