# Fisherman Roster Schema

**Tags:** fishermen, schema, animation-frames, characters, roster

**Specs:** 07 (schema, IN PROGRESS), 10 (regional human characters, TODO)

The roster is a JSON array of 40 playable characters stored at `~/.claude/commands/refs/gone-fishing/fishermen.json`. Characters are randomly selected on first `/gone-fishing` run and can be re-rolled with `/new-fisherman` without resetting catch history.

## Entry Schema

```json
{
  "id": "grizzled-pete",
  "name": "Grizzled Pete",
  "type": "human",
  "backstory": "Pete spent forty years on Lake Superior...",
  "frames": {
    "idle":        ["   |    ", "   |    ", "\\o/ ~   ", " |  ~~  ", "/ \\ ~~  "],
    "hooking":     ["  !!    ", "   |/   ", "\\o/ |   ", " |  *<  ", "/ \\ ~~  "],
    "retrieving":  ["   \\   ", "\\o/ |/  ", " |  ~<  ", "/ \\ ~~  "],
    "display":     ["\\o/     ", " |      ", "/ \\     "]
  }
}
```

| Field | Constraints |
|---|---|
| `id` | Kebab-case, unique, stable — stored in `profile.json`, never renamed after deployment |
| `name` | Display name, max 30 characters |
| `type` | `human` or `fantasy` |
| `backstory` | 2–4 sentences; must fit in intro card at 40-char inner width when word-wrapped |
| `frames` | Exactly four keys: `idle`, `hooking`, `retrieving`, `display` |

## Frame Dimensions (Canonical)

All frames must conform exactly:

| State | Row count | Row width |
|---|---|---|
| `idle` | 5 | 8 characters |
| `hooking` | 5 | 8 characters |
| `retrieving` | 4 | 8 characters |
| `display` | 3 | 8 characters |

Row width is strict — pad shorter rows with trailing spaces. No ANSI escape codes in frame strings; color is applied at render time by the renderer.

## The `type` Field

| Value | Description |
|---|---|
| `human` | Real-world human fishers grounded in specific geography |
| `fantasy` | Any non-human character: fantasy races, anthropomorphic animals, aquatic creatures |

Used for grouping in `/fishing-stats` output and as a subtitle label in the intro card.

## Visual Differentiation

No two `idle` frames may be identical. Characters must differ in at least head shape and body profile. Key variation axes: body shape, head type, rod style, stance, line angle, accessories.

## Backstory Voice

The roster spans deadpan realist (Grizzled Pete) to absurdist (fantasy characters). Both ends are valid; the rule is internal consistency within a single entry. Do not mix registers.

## Regional Human Characters (Spec 10)

Seven geographically grounded human characters are specified for addition:

| ID | Name | Region |
|---|---|---|
| `jean-pierre-boudreaux` | Jean-Pierre Boudreaux | Southeast Louisiana |
| `marisol-cayo` | Marisol Cayo | Florida Keys |
| `kodiak-karl` | Kodiak Karl | Alaska |
| `pacific-ray` | Pacific Ray | California |
| `big-muddy-delphine` | Big Muddy Delphine | Mississippi River |
| `bazza-gilhooly` | Bazza Gilhooly | Queensland, Australia |
| `pieter-van-der-meer` | Pieter van der Meer | Amsterdam, Netherlands |

Each has full draft frames, backstory, and visual differentiation table in Spec 10. Status: TODO (spec written, not yet implemented in `fishermen.json`).

## Reference: Grizzled Pete

Grizzled Pete is the canonical reference implementation. All new characters are validated against his frame dimensions and visual style. He is `human` type, standing at water's edge with a straight-up rod.

## Related

- [[gone-fishing-command]] — character selection on first run
- [[animation-system]] — frame states rendered by the statusline
- [[persistence-layer]] — `profile.json` stores the active `fishermanId`
- [[fishing-stats-command]] — displays character name, type, and full backstory
