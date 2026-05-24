# Fish Database (fish.json)

**Tags:** fish, database, schema, rarity, ASCII art

**Specs:** 04 (core schema, DONE), 09 (Southeast Louisiana batch, DONE)

The fish pool is a JSON array of real species stored at `~/.claude/commands/refs/gone-fishing/fish.json` (source: `.claude/commands/gone-fishing/fish.json`). It is read at catch time by [[shell-catch-hook]] and by `/fishing-stats`.

## Entry Schema

```json
{
  "id": "atlantic-bluefin-tuna",
  "common": "Atlantic Bluefin Tuna",
  "scientific": "Thunnus thynnus",
  "habitat": "saltwater",
  "rarity": "uncommon",
  "ascii": "><(((º>",
  "color": 21,
  "exp": 90,
  "flavor": "One of the largest bony fish in the sea."
}
```

| Field | Required | Description |
|---|---|---|
| `id` | Yes | Kebab-case unique identifier; stable across database edits |
| `common` | Yes | Common English name (or dominant local name — see Louisiana batch below) |
| `scientific` | Yes | Binomial scientific name |
| `habitat` | Yes | `freshwater` \| `saltwater` \| `brackish` \| `deep-sea` \| `tropical` \| `arctic` |
| `rarity` | Yes | `common` \| `uncommon` \| `rare` \| `legendary` — drives [[catch-probability]] weights |
| `ascii` | Yes | Single-line ASCII art, ≤22 chars, fish facing left |
| `color` | Yes | ANSI 256-color integer (0–255); applied as `\x1b[38;5;{color}m{ascii}\x1b[0m` |
| `exp` | Yes | EXP awarded on catch; fixed at authoring time. See [[leveling-system]] for tier ranges. |
| `flavor` | No | One-sentence flavor text shown in `/fishing-stats` |

## Rarity Distribution (100+ fish pool)

| Rarity | Target count | EXP range |
|---|---|---|
| `common` | ~60 | 15–40 |
| `uncommon` | ~25 | 45–80 |
| `rare` | ~12 | 90–150 |
| `legendary` | ~3 | 175–250 |

Legendary entries must be genuinely extraordinary species — coelacanth, oarfish, giant sturgeon. No fictional entries.

## ASCII Art Guidelines

- Single-line preferred; max 2 lines for large or complex fish.
- Width ≤ 22 characters to fit in the display frame.
- Orientation: fish facing left (toward the fisherman's hand).
- Common motifs: `><(((º>`, `><{{{{*>`, `>°))彡`, `><(((^>`

## Color Guidelines

Choose the most visually distinctive color for the species (body, stripe, or dominant hue). Use the ANSI 256-color chart for selection. Terminals without 256-color support fall back silently to the plain `ascii` value; skills must always check for color support before applying.

## Southeast Louisiana Regional Batch (Spec 09)

Approximately 28 species were added from three Louisiana habitat systems:

- **Freshwater/swamp:** cypress bayous and Atchafalaya backwaters. Species: Sacalait (White Crappie), Bluegill, Channel Catfish, Blue Catfish, Largemouth Bass, Spotted Bass, Goggle-eye (Warmouth), Yellow Bass, Longnose Gar, Spotted Gar, Alligator Gar, Bowfin (Choupique).
- **Brackish marsh/estuary:** Spotted Seatrout (Speckled Trout), Red Drum (Redfish), Black Drum, Sheepshead, Gulf Flounder, Striped Mullet, Atlantic Croaker, Gulf Sturgeon (legendary).
- **Nearshore Gulf:** Gulf Menhaden, Tripletail, Pompano, Cobia, Tarpon (rare and legendary variants), Spanish Mackerel, King Mackerel.

Regional Cajun/Creole common names (Sacalait, Choupique, Goggle-eye, Redfish, Speckled Trout) are used as the `common` field where they are dominant local usage. The `flavor` field explains the regional name and cultural context.

### Louisiana-Specific ASCII Notes

- Gar species: elongated snout — `--><(((º>` or `>--(((º>`
- Flounder: flattened motif — `><[[[º>`
- Drum family (redfish, black drum, croaker): round-bodied — `><(((*>`
- Bowfin/Choupique: blunt-headed — `>((({º>`

## Habitat Mapping for Louisiana Species

| Louisiana system | `habitat` value |
|---|---|
| Cypress swamp, bayou, Atchafalaya | `freshwater` |
| Coastal marsh, estuary, tidal pass | `brackish` |
| Nearshore Gulf, barrier island passes | `saltwater` |

## Related

- [[catch-probability]] — how `rarity` and `habitat` drive weighted selection
- [[leveling-system]] — `exp` field tier ranges
- [[animation-system]] — `color` and `ascii` used in statusline rendering
- [[persistence-layer]] — `fishId`, `common`, `rarity`, `exp` are snapshotted at catch time in `catches.json`
