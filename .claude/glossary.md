# Glossary

**Catch** — a fish caught during a catch roll. Appended to `catches.json` and reflected in `state.json`.

**Catch roll** — a 10% probability check that fires once per completed conversation turn when `/gone-fishing` is active. See Spec 03.

**EXP** — experience points awarded per catch. Stored in `catches.json`; totaled at runtime to derive level. Never stored directly. See Spec 08.

**Frame state** — one of four animation poses: `idle`, `hooking`, `retrieving`, `display`. Defined per-character in `fishermen.json`.

**Rarity** — the tier of a fish: `common`, `uncommon`, `rare`, or `legendary`. Drives weighted catch probability and EXP range. See Spec 03.

**Rod tier** — the visual upgrade level of the fishing rod, changing every 5 character levels (10 tiers total, Willow Branch → Celestial Rod). Applied at render time from level; not stored. See Spec 08.

**Atomic write** — the write strategy used for all persistence files: serialize to a `.tmp` file, then rename into place. Prevents partial writes.

**Statusline** — the Claude Code status bar. Fed by `~/.claude/statusline-command.sh`, which reads `state.json` to show the active fisherman name and catch state.

**Skill definition** — a `*.md` file in `~/.claude/commands/` whose frontmatter registers it as a slash command. Claude Code loads it as a system prompt when the command is invoked.
