# Spec 02 — Animation System

**Status:** `COMPLETE`
**Depends on:** [04 Fish Database](./04-fish-database.md)

---

## Purpose

Defines the ASCII art frames and sequencing logic for the fisherman overlay. All visual output is handled here.

## Frame States

Each frame set is defined per-character in `fishermen.json` under `.frames`. All frames are **~8 characters wide** (art only; water fill extends them further right at render time — see Rendering Rules). Characters must stay in the same position across all four states so transitions look like pose changes, not redraws.

### 1. Idle (5 rows)
The fisherman stands at the water's edge, rod extended, line in the water. Default state between turns.

- Row 1: rod tip / fishing line above water
- Row 2: fishing line dropping down
- Row 3: body at water surface — **must end with `~`** so water fill applies
- Rows 4–5: legs and feet in water — end with `~~`

### 2. Hooking (5 rows)
Triggered immediately when a catch is rolled. Held for < 2 seconds (driven by `animStartAt` elapsed time).

- `!!` or equivalent strike indicator above/beside head
- Line angles toward the fish
- Row 5 (bottom water row) unchanged from idle — ends with `~~`

### 3. Retrieving (4 rows)
Reel-in pose. Held from 2 s to 4 s elapsed. One row shorter — the two leg rows collapse into one.

- Row 1: rod tip unchanged
- Row 2: body/head with rod arm raised to reel
- Row 3: fish symbol (`~<` or `>^<`) at the surface — ends with `~`
- Row 4: bottom water row — ends with `~~`

### 4. Display (3 rows)
Held from 4 s elapsed until state is reset to idle on the next turn. No water rows.

- Row 1: head/upper body — fish ASCII art appended at render time (injected from `state.json`)
- Row 2: mid body — fish common name + EXP appended at render time
- Row 3: legs/feet

Fish art and name are loaded from `state.json` by `statusline-command.sh` — they are not stored in the frame definition.

## Sequencing

```
Idle → (10% roll hits) → Hooking (elapsed < 2s) → Retrieving (2s ≤ elapsed < 4s) → Display (elapsed ≥ 4s) → Idle
```

`elapsed = now - animStartAt`. The statusline script reads `state.json` on every poll cycle and selects the frame key accordingly. No background process is needed.

## Rendering Rules

Frames are rendered by `~/.claude/statusline-command.sh`, which outputs multi-line text consumed by Claude Code's `statusLine.type = "command"` integration.

### Terminal width detection

The script detects the usable column count via a process-tree PTY walk (reads `stty size` from the nearest ancestor with a controlling terminal). Fallbacks in order:

1. `tput cols`
2. `$COLUMNS`
3. Hardcoded `80`

### Right-alignment

A spacer of `MARGIN = 8` columns is reserved on the right. The art is positioned so that:

```
SPACER width = COLS − ART_W − MARGIN   (ART_W measured after water fill)
Total line   = SPACER + ART_W  (≤ COLS − MARGIN)
```

The spacer starts with U+2800 BRAILLE PATTERN BLANK to prevent Claude Code from stripping leading whitespace, followed by regular spaces.

### Dynamic water fill

Water fill is applied **before** `ART_W` is measured, so `PAD` correctly accounts for the extended rows. Any frame row whose last character is `~` is extended by `MARGIN − 3` additional `~` characters. This fills the right margin with water up to the clip boundary without triggering the renderer's ellipsis truncation.

- Rows not ending in `~` (rod, line, body above surface, display frame) are left as-is.
- Water fill amount = `MARGIN − 3` = 5 chars at the current margin setting.
- Order: apply fill → measure `ART_W` → compute `PAD` → output.

### Frame key selection

| `state.json` state | elapsed        | frame key    |
|--------------------|----------------|--------------|
| `"idle"`           | —              | `idle`       |
| `"caught"`         | < 2 s          | `hooking`    |
| `"caught"`         | 2 s – 3.99 s   | `retrieving` |
| `"caught"`         | ≥ 4 s          | `display`    |

## Acceptance Criteria

- [x] All four frame states render via the statusline command.
- [x] Frame key is selected by elapsed time from `animStartAt`.
- [x] Display frame injects fish art and name from `state.json`.
- [x] Art is right-aligned using detected terminal width with `MARGIN = 8`.
- [x] Water rows extend dynamically to fill the right margin.
- [x] Rendering is a no-op when terminal width < 80 columns.
- [x] Frame art is complete and visually consistent for all current characters.
