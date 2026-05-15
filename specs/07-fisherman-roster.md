# Spec 07 — Fisherman Roster

**Status:** `IN PROGRESS`
**Depends on:** [02 Animation System](./02-animation-system.md), [06 Persistence Layer](./06-persistence.md)

---

## Purpose

On first run, the user is assigned a randomly selected fisherman character from a roster of 40 unique individuals. Each character has a distinct name, backstory, and ASCII art that noticeably differs from others. The `/new-fisherman` skill lets users re-roll to a new character at any time.

---

## Skills

| Skill | Path | Description |
|-------|------|-------------|
| `/gone-fishing` | (existing) | On first run, triggers character selection before activation |
| `/new-fisherman` | `~/.claude/commands/new-fisherman.md` | Re-rolls to a new random character; shows the new character's name and intro |

---

## Character Selection Flow

### First Run
1. Check `~/.claude/commands/refs/gone-fishing/refs/profile.json` for a saved `fishermanId`.
2. If none exists: randomly select a character from `fishermen.json`, save it, then display a brief intro card showing the character's name and the first sentence of their backstory.
3. Proceed with normal `/gone-fishing` activation using the selected character's frames.

### Re-Roll (`/new-fisherman`)
1. Randomly select a character that is **different from the current one**.
2. Overwrite `fishermanId` in `profile.json`.
3. Display the new character's intro card.
4. The new character takes effect immediately on the next frame render.

---

## Data File

**Path:** `~/.claude/commands/refs/gone-fishing/fishermen.json`

```json
[
  {
    "id": "grizzled-pete",
    "name": "Grizzled Pete",
    "type": "human",
    "backstory": "Pete spent forty years on Lake Superior before his boat sank in a storm he swears he predicted. He fishes now not for sport or food, but because standing still makes his knees ache and the water doesn't ask questions.",
    "frames": {
      "idle":      ["   |  ", "   |  ", "\\o/ ~ ", " |  ~~", "/ \\ ~~"],
      "hooking":   ["  !! ", "   |/ ", "\\o/ | ", " |  *<", "/ \\ ~~"],
      "retrieving":["   \\ ", "\\o/ |/", " |  ~<", "/ \\ ~~"],
      "display":   ["\\o/   ", " |    ", "/ \\   "]
    }
  }
]
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Kebab-case unique identifier |
| `name` | Yes | Display name shown in stats and intro card |
| `type` | Yes | Character archetype (see roster below) |
| `backstory` | Yes | 2–4 sentence paragraph. Shown in `/fishing-stats`. |
| `frames` | Yes | Object with `idle`, `hooking`, `retrieving`, `display` keys. Each is an array of strings (one per row). |

---

## ASCII Art Differentiation

Characters must be **visually distinct** — not just a relabeled copy of the same stick figure. Key axes of variation:

| Axis | Examples |
|------|---------|
| Body shape | Tall/thin, wide/squat, hunched, floating, tentacled |
| Head | Human, cat ears, turtle shell, crown, horns, fish head, pointy hat |
| Rod style | Long pole, tiny twig, magic staff, bare hand, no rod (telekinesis) |
| Stance | Standing, sitting on a rock, hovering, crouched, perched on a stump |
| Line | Straight down, diagonal, multiple lines, glowing line |
| Extras | Pipe, hat, tail, wings, cape, visible scales, lantern |

At minimum, characters must differ in **head shape** and **body profile**.

---

## Roster (40 Characters)

Categories and representative entries. Full ASCII art is defined in `fishermen.json`.

### Humans (8)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `grizzled-pete` | Grizzled Pete | Hunched elder, long beard draping over rod |
| `captain-marina` | Captain Marina | Naval coat, standing at rigid attention |
| `tiny-tim-xl` | Tiny Tim XL | Enormous wide body, comically small rod |
| `the-meditator` | The Meditator | Cross-legged float above ground, line drops straight down |
| `baroness-von-hook` | Baroness von Hook | Top hat and monocle, elegant side-cast pose |
| `driftwood-dan` | Driftwood Dan | Sitting on a log, bare feet in the water |
| `chef-remy-fisher` | Chef Rémy Fisher | Tall chef's hat, holding rod like a whisk |
| `young-angler` | Young Angler | Small frame, oversized hat, tangled line |

### Fantasy Races (10)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `elder-thornbark` | Elder Thornbark | Ancient tree-ent; branches as arms, root-feet in water |
| `zyx-the-void-caller` | Zyx the Void-Caller | Floating dark elf, line made of shadow tendrils |
| `boulderfoot` | Boulderfoot | Stone giant; sits in the lake, using a ship mast as a rod |
| `pixie-flit` | Pixie Flit | Tiny winged figure hovering at eye level with the water |
| `mire-witch-agda` | Mire-Witch Agda | Swamp hag hunched over, crooked staff-rod, floating hat |
| `ironclad-gorm` | Ironclad Gorm | Dwarf in full plate armor, rod is an axe handle with line tied on |
| `seraphel` | Seraphel | Radiant angel, feathered wings spread, golden rod |
| `the-lich-king-angler` | The Lich King Angler | Skeletal figure, bones visible, glowing eye sockets |
| `mosswhisper` | Mosswhisper | Forest sprite, sitting on a giant mushroom cap |
| `runeweaver-brix` | Runeweaver Brix | Gnome with spinning arcane glyphs orbiting the rod tip |

### Cat People (5)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `purrlock-holmes` | Purrlock Holmes | Deerstalker hat, magnifying glass in off-hand, intense stare at water |
| `duchess-fluffington` | Duchess Fluffington | Sitting primly, tail curled around feet, rod balanced on nose |
| `captain-catastrophe` | Captain Catastrophe | Tangled in the fishing line, rod upside down, still somehow catching fish |
| `sensei-whiskers` | Sensei Whiskers | Ancient cat in gi, one-paw meditative rod hold |
| `tabby-mcbaitface` | Tabby McBaitface | Normal cat crouched at the edge, fully focused, paw on the line |

### Turtle People (5)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `shell-shocked-sal` | Shell-Shocked Sal | Half-retracted into shell, rod poking out beside head |
| `ancient-one-kessho` | Ancient One Kessho | Enormous mossy shell, sitting in shallow water like an island |
| `ninja-swift` | Ninja Swift | Crouched low in stealth pose, rod held like a weapon |
| `aldous-the-patient` | Aldous the Patient | Asleep standing up, line in water, still catching fish |
| `terrapin-belle` | Terrapin Belle | Shell decorated with painted flowers, parasol in off-hand |

### Aquatic & Deep Sea (5)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `the-fish` | The Fish | A fish. Fishing. For other fish. Holds a tiny rod in its fin. The line goes sideways. |
| `kraken-jr` | Kraken Jr. | Baby kraken, one tentacle holds rod, others splash playfully |
| `captain-brine` | Captain Brine | Merman in a naval coat, tail flipping out of water |
| `deep-lurker-vo` | Deep-Lurker Vo | Anglerfish standing upright, bioluminescent lure as rod tip |
| `bubble-witch` | Bubble Witch | Jellyfish-person, translucent bell-head, tentacles dangle |

### Miscellaneous Creatures (7)
| ID | Name | Distinguishing Trait |
|----|------|----------------------|
| `sir-hops-a-lot` | Sir Hops-a-Lot | Frog knight in full armor, lance-rod, lily pad platform |
| `biscuit-the-bear` | Biscuit the Bear | Bear standing in the river doing it the old-fashioned way (swatting), but holding a rod too just in case |
| `professor-cluck` | Professor Cluck | Chicken in academic robes and tiny spectacles |
| `rustle-the-raccoon` | Rustle the Raccoon | Raccoon with five stolen rods, fishing all at once |
| `grandmother-moth` | Grandmother Moth | Elderly moth drawn to a lantern-tipped rod |
| `rocketship-rex` | Rocketship Rex | Dinosaur in an astronaut suit, fishing rod attached to the helmet |
| `the-fog` | The Fog | An amorphous mist with a hat and a rod. The rod floats. The fish are terrified. |

---

## Intro Card (shown on first run and re-roll)

```
╔══════════════════════════════════════════╗
║  Your fisherman:  Grizzled Pete          ║
║  ─────────────────────────────────────── ║
║  Pete spent forty years on Lake          ║
║  Superior before his boat sank in a      ║
║  storm he swears he predicted...         ║
╚══════════════════════════════════════════╝
```

- Backstory is word-wrapped to fit a 40-char inner width.
- Show only the first ~2 sentences in the intro card; full backstory appears in `/fishing-stats`.

---

## Persistence

The currently selected fisherman is stored in `profile.json` (see [Spec 06](./06-persistence.md) for the atomic write pattern):

```json
{
  "version": 1,
  "fishermanId": "grizzled-pete",
  "assignedAt": "2026-05-14T10:00:00.000Z"
}
```

`profile.json` lives alongside `catches.json` in `~/.claude/commands/refs/gone-fishing/refs/`.

---

## Acceptance Criteria

- [ ] `fishermen.json` contains exactly 40 entries, each with all required fields.
- [ ] All 40 characters have visually distinct idle frames — no two frames are identical.
- [ ] On first `/gone-fishing` run with no `profile.json`, a character is randomly selected and saved.
- [ ] The intro card renders with the correct name and backstory excerpt.
- [ ] `/new-fisherman` selects a different character than the current one and updates `profile.json`.
- [ ] The new character's frames are used immediately on the next render cycle.
- [ ] `/fishing-stats` shows the current fisherman's full name and full backstory paragraph.
- [ ] Re-rolling does not reset or affect `catches.json`.
