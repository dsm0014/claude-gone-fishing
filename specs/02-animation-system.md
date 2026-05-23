# Spec 02 — Animation System

**Status:** `COMPLETE`
**Depends on:** [04 Fish Database](./04-fish-database.md)

---

## Purpose

Defines the statusline glyph states and fish color rendering for the fisherman overlay. All visual output is delivered through the Claude Code statusline via `statusline-command.sh`.

## Statusline Glyph States

The statusline shows the active fisherman's name followed by a state glyph. There are three states:

| Glyph | Condition |
|---|---|
| `~~~~~` | Profile exists but `/gone-fishing` not run this session (`active: false`) |
| `~~*~~` | `/gone-fishing` active, waiting between turns |
| `~>!<~  <name> <ascii>` | Fish caught — displays colored fish name and ASCII art |

Example statusline output:

```
claude-sonnet-4-6 | ctx:12% | 🎣 Kodiak Karl  ~~*~~
```

On a catch:

```
claude-sonnet-4-6 | ctx:14% | 🎣 Kodiak Karl  ~>!<~  Bluefin Tuna ><(((°>
```

## Fish Color Rendering

When a catch is displayed, the fish ASCII art is rendered in its species color using ANSI 256-color:

```sh
printf '\033[38;5;%sm%s\033[0m' "$fish_color" "$fish_ascii"
```

`fish_color` is the 256-color code stored in the fish database entry (see [Spec 04](./04-fish-database.md)). The fish name is rendered in the default terminal color immediately after the colored art.

## State File

The statusline script reads `~/.claude/commands/refs/gone-fishing/refs/state.json` on every tick. Fields used:

- `fishermanName` — displayed in the statusline
- `state` — `"idle"` or `"caught"`
- `active` — `true` when `/gone-fishing` has been invoked this session
- `catch.common` — fish common name (caught state only)
- `catch.ascii` — fish ASCII art (caught state only)
- `catch.color` — ANSI 256-color code (caught state only)

No background process or cursor positioning is needed — the statusline polling drives all state transitions.

## Acceptance Criteria

- [x] Statusline shows `~~~~~` when a profile exists but the session is inactive.
- [x] Statusline shows `~~*~~` while `/gone-fishing` is active between turns.
- [x] Statusline shows `~>!<~` with the fish name and colored ASCII art on a catch.
- [x] Fish ASCII art renders in its species ANSI 256-color.
- [x] Statusline falls back gracefully (shows model/ctx only) when no profile exists.
