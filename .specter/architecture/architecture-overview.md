# Claude Gone Fishing — Architecture Overview

**Tags:** architecture, overview, hooks, persistence, statusline

`claude-gone-fishing` is a Claude Code skill that runs an ASCII art fishing minigame alongside normal coding sessions. It has no server, no background daemon, and no persistent process — it is built entirely from shell scripts, JSON data files, and Claude Code's native slash commands and hook system.

## Core Idea

Every time Claude finishes a response, a bash `Stop` hook fires silently and rolls a 10% chance of catching a fish. If the roll hits, the hook selects a species from a weighted pool, writes the result to `state.json` and `catches.json`, and prints one notification line to the terminal. The statusline script picks up `state.json` on its next polling tick and renders the fish in the status bar. Claude itself sees nothing; the hook runs invisibly after the model has already replied.

## Component Map

```
User prompt
  │
  ▼
UserPromptSubmit hook (gone-fishing-session.sh)
  │  – Checks profile.json; creates session.json if stale
  │  – Injects "[gone-fishing] <Name> is on the line" into context
  │  – Injects catch announcement if state.json has an unannounced catch
  ▼
Claude responds
  │
  ▼
Stop hook (gone-fishing-catch-hook.sh)
  │  – Reads session.json (gate: absent or > 4 h old → exit)
  │  – Reads profile.json (gate: absent → exit)
  │  – Rolls RANDOM % 1000 < 100 (10% chance)
  │  – Reads fish.json; selects weighted species
  │  – Writes state.json atomically
  │  – Appends catches.json atomically
  │  – Prints "🎣 <fish> <ascii> (+N EXP)" to terminal
  ▼
statusline-command.sh (polled by Claude Code status bar)
     – Reads session.json for active/inactive glyph
     – Reads state.json for caught-state display
     – Reads catches.json for level derivation
     – Renders: model | ctx% | 🎣 <Name>  ~~*~~  Lv.N
```

## Data Flow

All persistent state is local to `~/.claude/commands/refs/gone-fishing/refs/`:

| File | Written by | Read by |
|---|---|---|
| `profile.json` | `/gone-fishing` command (first run or `/new-fisherman`) | session hook, catch hook |
| `session.json` | Session hook, `/gone-fishing` command | session hook, catch hook, statusline |
| `state.json` | Catch hook | session hook (catch announcement), statusline |
| `catches.json` | Catch hook | `/fishing-stats` command, statusline (level) |

See [[persistence-layer]] for full schemas and atomic-write rules.

## Slash Commands

Three user-facing slash commands are defined as Markdown files in `.claude/commands/gone-fishing/` and deployed to `~/.claude/commands/`:

- **`/gone-fishing`** — activates the session overlay; assigns a fisherman on first run. See [[gone-fishing-command]].
- **`/fishing-stats`** — renders the full catch history panel. See [[fishing-stats-command]].
- **`/new-fisherman`** — re-rolls the character without resetting catch history.

## Data Files

Two JSON files are bundled with the skill and deployed to `~/.claude/commands/refs/gone-fishing/`:

- **`fish.json`** — 100+ catchable species. See [[fish-database]] and [[southeast-louisiana-fish]].
- **`fishermen.json`** — 40 playable characters. See [[fisherman-roster]].

## Hook Registration

`scripts/install.sh` writes both hook paths into `~/.claude/settings.json` under `hooks.UserPromptSubmit` and `hooks.Stop`. It also sets `statusLine.type = "command"` pointing at the statusline script, and adds `Read`/`Write`/`Bash(mv)` allowlist entries so routine data file operations never prompt for permission.

## Stateless-by-Design Choices

- Level and total EXP are never stored — always derived at runtime from `catches.json`. See [[leveling-system]].
- The statusline handles the caught→idle visual transition autonomously using `caughtAt` elapsed time (120 s window), without Claude writing a reset.
- No-catch turns (90%) produce zero file I/O in the catch hook.
- Session expiry is implicit: session hook and catch hook both check that `activatedAt` in `session.json` is within their respective windows (8 h and 4 h) before proceeding.

## Install

```bash
git clone https://github.com/dsm0014/claude-gone-fishing
cd claude-gone-fishing
bash scripts/install.sh
```

After install, run `/gone-fishing` once to assign a fisherman. Every subsequent session activates automatically via the `UserPromptSubmit` hook.
