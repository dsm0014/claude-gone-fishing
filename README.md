# claude-gone-fishing

A Claude Code skill that puts a fisherman in your terminal. While you work, Pete fishes. Every conversation turn has a 10% chance of landing something.

## Install

```bash
git clone https://github.com/dsm0014/claude-gone-fishing
cd claude-gone-fishing
bash scripts/install.sh
```

The install script copies the skill files to `~/.claude/commands/`, sets up the status bar, and adds the necessary permissions to `~/.claude/settings.json` so you won't get prompted on every cast.

## Commands

| Command | Description |
|---|---|
| `/gone-fishing` | Activates the overlay for the session. Assigns a fisherman on first run. |
| `/fishing-stats` | Shows your fisherman's profile and full catch history. |
| `/new-fisherman` | Re-rolls your character. Catch history is preserved. |

## How it works

- The catch roll fires after each completed conversation turn — not during.
- Fish are weighted by rarity: common, uncommon, rare, legendary.
- EXP is earned per catch and totaled at runtime to determine your level (50 levels).
- All state is persisted in `~/.claude/commands/refs/gone-fishing/refs/`.
- Running `/clear` ends the session and stops the overlay. `/compact` is fine — the skill survives compaction.
