# Spec 07 — Fisherman Roster Schema

**Status:** `IN PROGRESS`
**Depends on:** [02 Animation System](./02-animation-system.md), [06 Persistence Layer](./06-persistence.md)

---

## Purpose

Define the schema, field constraints, and frame dimensions that every entry in `fishermen.json` must satisfy. This spec is not a roster — individual character groups are defined in their own specs (see [Adding New Fishermen](#adding-new-fishermen) below).

---

## Data File

**Installed path:** `~/.claude/commands/refs/gone-fishing/fishermen.json`
**Source path:** `.claude/commands/gone-fishing/fishermen.json`

A JSON array of fisherman objects. Order within the array is not significant; character selection is random.

---

## Schema

```json
{
  "id":        "<string>",
  "name":      "<string>",
  "type":      "<string>",
  "backstory": "<string>",
  "frames": {
    "idle":       ["<string>", ...],
    "hooking":    ["<string>", ...],
    "retrieving": ["<string>", ...],
    "display":    ["<string>", ...]
  }
}
```

### Field Definitions

| Field | Required | Type | Constraints |
|-------|----------|------|-------------|
| `id` | Yes | string | Kebab-case. Unique across all entries. Stable — never renamed after the character is in production (it is stored in `profile.json`). |
| `name` | Yes | string | Display name. Shown in the intro card, status line, and `/fishing-stats`. Max 30 characters. |
| `type` | Yes | string | One of the valid type values listed below. |
| `backstory` | Yes | string | 2–4 sentences. No hard character limit, but must fit in the intro card at 40-char inner width when word-wrapped. Shown in full in `/fishing-stats`; first ~2 sentences in the intro card. |
| `frames` | Yes | object | Exactly four keys: `idle`, `hooking`, `retrieving`, `display`. Each value is an array of equal-width strings. |

---

## Frame Dimensions (Canonical)

All frames must conform to these dimensions. They are derived from the Spec 10 regional human characters, which are the reference implementation.

| State | Row count | Row width |
|-------|-----------|-----------|
| `idle` | 5 | 8 characters |
| `hooking` | 5 | 8 characters |
| `retrieving` | 4 | 8 characters |
| `display` | 3 | 8 characters |

**Row width is strict.** Pad shorter rows with trailing spaces. Do not truncate. Every row in a frame array must be exactly 8 characters — no exceptions.

**Row count is strict.** The animation system indexes rows by position; mismatched counts break rendering. An `idle` frame must always be 5 rows.

**ASCII only.** Frame strings must contain only printable ASCII characters (0x20–0x7E). ANSI escape codes are applied at render time by the renderer, not stored in the data file.

---

## Visual Differentiation

Characters must be visually distinct — not just a relabeled copy of the same stick figure. The minimum requirement is that no two `idle` frames are identical. Key variation axes:

| Axis | Examples |
|------|---------|
| Body shape | Tall/thin, wide/squat, hunched, floating, tentacled |
| Head | Human, cat ears, turtle shell, crown, horns, fish head, pointy hat |
| Rod style | Long pole, tiny twig, magic staff, bare hand, no rod (telekinesis) |
| Stance | Standing, sitting on a rock, hovering, crouched, perched on a stump |
| Line | Straight down, diagonal, multiple lines, glowing (rendered) |
| Extras | Pipe, hat, tail, wings, cape, visible scales, lantern |

At minimum, characters must differ in **head shape** and **body profile**.

---

## The `type` Field

`type` is a controlled vocabulary. Valid values:

| Value | Description |
|-------|-------------|
| `human` | Real-world human fishers, grounded in specific geography and technique |
| `fantasy` | Fantasy race characters — elves, dwarves, tree-ents, undead, etc. |
| `cat` | Anthropomorphic cat characters |
| `turtle` | Anthropomorphic turtle characters |
| `aquatic` | Aquatic and deep-sea creatures |
| `creature` | Other anthropomorphic or non-human creatures not covered above |

**Mechanical uses:**

1. **`/fishing-stats` grouping.** Characters are listed under a section header derived from their type (e.g., `Human Fishermen`, `Fantasy Races`, `Cat People`). This is the primary use.
2. **`/new-fisherman` reroll pool.** Currently all types are pooled together. The `type` field enables future filtering if the user wants to reroll within a category — do not remove or change `type` values on existing characters without considering this.
3. **Intro card subtitle.** The intro card displays the type as a short label below the character name (e.g., `Human · Grizzled Pete`). Type values with underscores or multiple words should be title-cased at render time.

---

## Backstory Voice

The roster spans a spectrum from deadpan realist (Grizzled Pete, regional humans) to absurdist (The Fog, Rocketship Rex). Both ends are valid. The rule is internal consistency: a realistic character should read like they could exist; an absurdist character should commit fully to the bit without hedging.

Avoid mixing registers within a single entry. A backstory that opens with gritty regional detail and ends with a joke about teleporting fish feels unfinished. Pick a lane and stay in it.

---

## Reference Implementation

Grizzled Pete is the canonical reference entry. His frames are shown here at the canonical 8×(5/5/4/3) dimensions:

```json
{
  "id": "grizzled-pete",
  "name": "Grizzled Pete",
  "type": "human",
  "backstory": "Pete spent forty years on Lake Superior before his boat sank in a storm he swears he predicted. He fishes now not for sport or food, because standing still makes his knees ache and the water doesn't ask questions. His tackle box holds more memories than lures, and his thermos has never once contained coffee.",
  "frames": {
    "idle":        ["   |    ", "   |    ", "\\o/ ~   ", " |  ~~  ", "/ \\ ~~  "],
    "hooking":     ["  !!    ", "   |/   ", "\\o/ |   ", " |  *<  ", "/ \\ ~~  "],
    "retrieving":  ["   \\   ", "\\o/ |/  ", " |  ~<  ", "/ \\ ~~  "],
    "display":     ["\\o/     ", " |      ", "/ \\     "]
  }
}
```

---

## Adding New Fishermen

New characters are added in batches, each with its own spec. Each group spec should:

1. List the characters being added (name, ID, type, region or concept)
2. Provide a full backstory for each character
3. Provide draft frame art with annotations explaining the visual choices
4. Include a visual differentiation table showing how each new character distinguishes itself from Pete and from other characters in the same batch
5. Include acceptance criteria that can be checked mechanically

[Spec 10 — Regional Human Fishermen](./10-regional-fishermen.md) is the model to follow. It covers 7 human characters and shows the expected level of detail.

---

## Acceptance Criteria

- [ ] `fishermen.json` contains exactly 40 entries, each with all required fields populated.
- [ ] Every entry has a `type` value from the valid set.
- [ ] All frame arrays conform to the canonical row counts (5/5/4/3).
- [ ] All frame rows are exactly 8 characters wide.
- [ ] No two `idle` frames across all 40 entries are identical.
- [ ] On first `/gone-fishing` run with no `profile.json`, a character is randomly selected and saved.
- [ ] The intro card renders with the correct name, type label, and backstory excerpt.
- [ ] `/new-fisherman` selects a character different from the current one and updates `profile.json`.
- [ ] `/fishing-stats` shows the full name, type, and full backstory paragraph, with characters grouped by type.
- [ ] Re-rolling does not reset or affect `catches.json`.
