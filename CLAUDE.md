# CLAUDE.md

`claude-gone-fishing` is a Claude Code skill that renders an ASCII art fisherman in the terminal. Three user-invocable slash commands:

- `/gone-fishing` — enables the fisherman overlay; 10% per-turn catch chance; assigns a character on first run.
- `/fishing-stats` — displays the current fisherman's profile and all catch history.
- `/new-fisherman` — re-rolls the fisherman character without resetting catch history.

@.claude/ARCHITECTURE.md
@.claude/glossary.md

## Key Constraints

- The catch roll fires **after each conversation turn completes**, not during.
- All persistent data writes go to `~/.claude/commands/refs/gone-fishing/refs/`, never to the project directory.
- Fish data is deterministic — always loaded from the bundled `fish.json`.
- Fisherman renders on the **far right** of the terminal via ANSI positioning (not yet implemented; currently text-only).
