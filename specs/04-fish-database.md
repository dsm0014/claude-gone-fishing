# Spec 04 — Fish Database

**Status:** `TODO`

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
~/.claude/skills/gone-fishing/fish.json
```

Each entry:
```json
{
  "id": "atlantic-bluefin-tuna",
  "common": "Atlantic Bluefin Tuna",
  "scientific": "Thunnus thynnus",
  "habitat": "saltwater",
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
| `habitat` | Yes | `freshwater` \| `saltwater` \| `brackish` \| `deep-sea` |
| `ascii` | Yes | Single-line ASCII art of the fish (fits in ~20 chars) |
| `exp` | Yes | EXP awarded on catch — see [Spec 08](./08-leveling-system.md) for tier ranges |
| `flavor` | No | One sentence of flavor text shown in stats |

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
- [ ] Species span at least 4 habitat types.
- [ ] All species are real, verifiable fish.
- [ ] Every entry has an `exp` value within the correct tier range (see Spec 08).
