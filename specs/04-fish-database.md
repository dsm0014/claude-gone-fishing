# Spec 04 — Fish Database

**Status:** `IN PROGRESS`

---

## Purpose

Defines the structure and content requirements for the pool of catchable fish. All fish are real species.

## Requirements

- **Minimum 100 unique species.**
- Each entry must include a common name, scientific name, and ASCII art.
- Fish are sourced from a variety of habitats: freshwater, saltwater, deep sea, tropical, arctic, etc.
- No fictional or joke entries.

## Entry Schema

Stored as a JSON array at:
```
~/.claude/commands/refs/gone-fishing/fish.json
```

Each entry:
```json
{
  "id": "atlantic-bluefin-tuna",
  "common": "Atlantic Bluefin Tuna",
  "scientific": "Thunnus thynnus",
  "habitat": "saltwater",
  "rarity": "uncommon",
  "ascii": "><(((º>",
  "exp": 90,
  "flavor": "One of the largest bony fish in the sea."
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Kebab-case unique identifier |
| `common` | Yes | Common English name |
| `scientific` | Yes | Binomial scientific name |
| `habitat` | Yes | `freshwater` \| `saltwater` \| `brackish` \| `deep-sea` \| `tropical` \| `arctic` |
| `rarity` | Yes | `common` \| `uncommon` \| `rare` \| `legendary` — drives weighted catch probability (see [Spec 03](./03-catch-probability.md)) |
| `ascii` | Yes | Single-line ASCII art of the fish (fits in ~20 chars) |
| `exp` | Yes | EXP awarded on catch — see [Spec 08](./08-leveling-system.md) for tier ranges |
| `flavor` | No | One sentence of flavor text shown in stats |

## Rarity Distribution

The full pool of 100+ fish must follow this approximate split:

| Rarity | Target Count | EXP Range |
|--------|-------------|-----------|
| `common` | ~60 | 15–40 |
| `uncommon` | ~25 | 45–80 |
| `rare` | ~12 | 90–150 |
| `legendary` | ~3 | 175–250 |

Legendary species should be genuinely extraordinary — coelacanth, oarfish, giant sturgeon, and similar. Rare species are unusual but not mythical. EXP ranges must align with [Spec 08](./08-leveling-system.md).

## ASCII Art Guidelines

- Single-line preferred; max 2 lines for large/complex fish.
- Width ≤ 22 characters to fit in the display frame.
- Orientation: fish facing left (toward the fisherman's hand).
- Common motifs: `><(((º>`, `><{{{{*>`, `>°))彡`, `><(((^>`

## Sample Species List (non-exhaustive)

Freshwater: Largemouth Bass, Rainbow Trout, Catfish, Bluegill, Carp, Pike, Walleye, Perch, Crappie, Muskellunge, Brook Trout, Steelhead, Sturgeon, Gar, Bowfin, Tilapia, Sunfish

Saltwater: Atlantic Bluefin Tuna, Mahi-Mahi, Swordfish, Marlin, Red Snapper, Grouper, Flounder, Halibut, Striped Bass, Tarpon, Bluefish, Wahoo, Amberjack, Cobia, Permit, Pompano, Sea Bass, Barracuda, Bonefish, Redfish

Deep Sea: Anglerfish, Oarfish, Giant Squid (honorary), Viperfish, Gulper Eel, Lanternfish, Dragonfish, Fangtooth, Barreleye, Blobfish

Tropical: Clownfish, Parrotfish, Triggerfish, Lionfish, Pufferfish, Surgeonfish, Butterflyfish, Wrasse, Moray Eel, Goby

Arctic/Cold: Arctic Char, Cod, Halibut, Pollock, Capelin, Herring, Mackerel, Sprat, Sablefish, Lingcod

Rare/Unusual: Coelacanth, Paddlefish, Arapaima, Alligator Gar, Giant Trevally, Roosterfish, Dorado, Taimen

## Acceptance Criteria

- [ ] At least 100 entries in `fish.json`.
- [ ] Every entry passes schema validation (all required fields present, `id` is unique).
- [ ] Every `ascii` field is ≤ 22 characters wide.
- [ ] Species span all 6 habitat types.
- [ ] All species are real, verifiable fish.
- [ ] Every entry has a `rarity` value of `common`, `uncommon`, `rare`, or `legendary`.
- [ ] Rarity distribution approximates 60 / 25 / 12 / 3 across the pool.
- [ ] Every entry has an `exp` value within the correct tier range for its rarity (see Spec 08).
