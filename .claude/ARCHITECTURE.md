# Architecture

## File Layout

**Source (this repo):**
```
.claude/commands/gone-fishing/
├── gone-fishing.md        # /gone-fishing skill definition
├── fishing-stats.md       # /fishing-stats skill definition
├── new-fisherman.md       # /new-fisherman skill definition
├── fish.json              # catchable fish database
├── fishermen.json         # playable character roster
└── .gitignore
scripts/
└── install.sh             # deploys to ~/.claude; writes statusline-command.sh
```

**Installed (`scripts/install.sh`):**
```
~/.claude/
├── commands/
│   ├── gone-fishing.md
│   ├── fishing-stats.md
│   ├── new-fisherman.md
│   └── refs/
│       └── gone-fishing/          ← read-only data
│           ├── fish.json
│           ├── fishermen.json
│           └── refs/              ← read/write persistence (runtime-created)
│               ├── profile.json
│               ├── catches.json
│               └── state.json
└── statusline-command.sh
```

## Components

### Skill definitions (`*.md`)
System prompts loaded by Claude Code when a slash command is invoked. Each file describes activation logic, the per-turn catch roll, rendering behavior, and data paths.

### `fishermen.json`
Playable characters. Each entry: `id`, `name`, `type`, `backstory` (2–4 sentences), and a `frames` object with `idle`, `hooking`, `retrieving`, `display` ASCII art arrays.

**Current state:** 1 character (Grizzled Pete); frames not yet in data file. Target: 40 visually distinct characters. See Spec 07.

### `fish.json`
Catchable species. Each entry: `id`, `common`, `scientific`, `habitat`, `rarity`, `ascii` (≤22 chars, facing left), `color` (ANSI 256-color code), `exp`, optional `flavor`.

**Current state:** 105 species across all 6 habitat types and 4 rarity tiers (57 common / 32 uncommon / 13 rare / 3 legendary). See Spec 04.

### Animation frames
Four frame states per character (arrays of strings, one per terminal row):
1. **Idle** — fisherman at water's edge, line in water
2. **Hooking** — line snaps taut, fish struck
3. **Retrieving** — reel-in motion (2–3 sub-frames)
4. **Display** — fisherman holds up the caught fish with its name

**Current state:** Not yet implemented. Catches produce a text notification instead. See Spec 02.

### Leveling system
EXP is derived at runtime by summing `catches[].exp` in `catches.json` — never stored directly. 50 levels; threshold = `100 + (n-1) * 50` XP. Every 5 levels the rod upgrades through 10 visual tiers (Willow Branch → Celestial Rod). See Spec 08.

**Current state:** Not yet implemented.

### Statusline integration
`install.sh` writes `~/.claude/statusline-command.sh` and sets `statusLine.type = "command"` in `~/.claude/settings.json`. The script reads `state.json` to display the active fisherman's name and catch state in the Claude Code status bar.

### Persistence (`refs/`)
- `catches.json` — append-only log: `{ version, catches: [{ fishId, common, rarity, exp, timestamp }] }`
- `profile.json` — active character: `{ version, fishermanId, assignedAt }`
- `state.json` — statusline state: `{ version, fishermanName, state, catch }` where caught `catch` includes `{ fishId, common, ascii, color, exp }`
- All writes are atomic: write to `.tmp`, then rename.
