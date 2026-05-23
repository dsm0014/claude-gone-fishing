# CLAUDE.md

`claude-gone-fishing` is a Claude Code skill that renders an ASCII art fisherman in the terminal. Three user-invocable slash commands:

- `/gone-fishing` — enables the fisherman overlay; 10% per-turn catch chance; assigns a character on first run.
- `/fishing-stats` — displays the current fisherman's profile and all catch history.
- `/new-fisherman` — re-rolls the fisherman character without resetting catch history.

@.claude/ARCHITECTURE.md

## Key Constraints

- The catch roll fires **after each conversation turn completes**, not during.
- All persistent data writes go to `~/.claude/commands/refs/gone-fishing/refs/`, never to the project directory.
- Fish data is deterministic — always loaded from the bundled `fish.json`.
- Fisherman renders on the **far right** of the terminal via ANSI positioning (Spec 02).

## Conventions

- Skill source files live in `.claude/commands/gone-fishing/`. Deployed to `~/.claude/commands/` via `scripts/install.sh`. Never write skill or data files directly to `~/.claude/`.
- New specs go in `specs/` numbered sequentially. Always update `specs/00-index.md` when adding a spec.
- Changes to `fish.json` or `fishermen.json` require a reinstall (`scripts/install.sh`) to take effect at the installed path.
- Worktrees go in `../claude-gone-fishing-<name>/` (sibling to the main repo). Use them for parallel branch work; avoid checking out multiple branches in the same working tree.
- Persistent data lives in `~/.claude/commands/refs/gone-fishing/refs/`. It is never committed to the repo.
- **Atomic write:** serialize to a `.tmp` file, then rename into place. Used for all persistence writes.
- **Skill definition:** a `*.md` file in `~/.claude/commands/` registered via frontmatter; Claude Code loads it as a system prompt when the command is invoked.
