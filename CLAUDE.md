# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`claude-gone-fishing` is a Claude Code skill that renders an ASCII art fisherman in the terminal. It is modeled after the `/buddy` skill pattern. Two user-invocable slash commands are exposed:

- `/gone-fishing` — enables the fisherman overlay. On first run, randomly assigns a character from the 40-person roster. After each conversation turn, there is a 10% chance of "catching a fish," triggering a multi-frame hook → retrieve → display animation.
- `/fishing-stats` — displays the current fisherman's name and full backstory, plus statistics about all fish caught across sessions.
- `/new-fisherman` — re-rolls the user's fisherman character to a new random pick from the roster.

## Skill Installation & File Layout

Skills live under `~/.claude/skills/`. This skill installs to:

```
~/.claude/skills/gone-fishing/
├── gone-fishing.md        # skill definition (invoked by /gone-fishing)
├── fishing-stats.md       # skill definition (invoked by /fishing-stats)
├── new-fisherman.md       # skill definition (invoked by /new-fisherman)
├── fish.json              # database of 100+ catchable fish species
├── fishermen.json         # roster of 40 playable fisherman characters
└── refs/
    ├── catches.json       # cumulative catch log
    └── profile.json       # currently selected fisherman character
```

The `refs/` directory is the persistence layer for fishing data — it lives in the user's home directory so catch history survives across projects.

## Architecture

### Skill definitions (`*.md` files)
Each skill file contains a system prompt that Claude Code loads when the slash command is invoked. These files describe rendering logic, trigger conditions, and where to read/write data.

### Fisherman roster (`fishermen.json`)
40 unique playable characters spanning humans, fantasy races, cat people, turtle people, aquatic creatures, and misc creatures. Each entry has:
- `id`, `name`, `type`, `backstory` (2–4 sentences)
- `frames` object with `idle`, `hooking`, `retrieving`, and `display` ASCII art arrays

Characters must be visually distinct — differing in head, body shape, rod style, and stance. See Spec 07 for the full roster and differentiation rules.

### Fish database (`fish.json`)
100+ real fish species. Each entry: `id`, `common`, `scientific`, `habitat`, `ascii` (≤22 chars, fish facing left), `exp` (EXP awarded on catch), optional `flavor`.

### Animation frames
Four states per character, each an array of strings (one string per terminal row):
1. **Idle** — fisherman at water's edge, line in water
2. **Hooking** — line taut, fish struck
3. **Retrieving** — reel-in motion (2–3 sub-frames)
4. **Display** — fisherman holds up the caught fish with its name

### Leveling system
Catching fish awards EXP. Each fish has a fixed `exp` value (15–250 depending on rarity). Level is derived at runtime by summing all `exp` values in `catches.json` — never stored directly. 50 levels total; threshold grows linearly (`100 + (n-1) * 50` XP per level). Every 5 levels the rod upgrades through 10 visual tiers (Willow Branch → Celestial Rod). An EXP bar renders below the fisherman's idle frame. See Spec 08.

### Persistence (`refs/`)
- `catches.json` — append-only catch log: `{ version, catches: [{ fishId, common, exp, timestamp }] }`
- `profile.json` — selected character: `{ version, fishermanId, assignedAt }`
- Both files use atomic writes (write to `.tmp`, rename into place).

## Key Constraints

- The fisherman renders on the **far right** of the terminal — use ANSI escape codes or fixed-width padding to avoid colliding with Claude's text output.
- The catch roll (10%) fires **after each conversation turn completes**, not during.
- Fish data must be deterministic — same fish pool every session, loaded from the bundled fish list.
- All persistent data writes go to `~/.claude/skills/gone-fishing/refs/`, never to the project directory.
