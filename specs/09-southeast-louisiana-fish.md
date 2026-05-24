# Spec 09 — Southeast Louisiana Regional Fish

**Status:** `DONE`

---

## Purpose

Expand `fish.json` with species representative of Southeast Louisiana's fishing culture — covering the cypress swamps, bayous, coastal marshes, and nearshore Gulf waters that define the region. These entries integrate with the existing fish pool and must conform to [Spec 04](./04-fish-database.md).

## Background

Southeast Louisiana sits at the confluence of the Mississippi River delta, vast brackish marshes, and the Gulf of Mexico. The result is one of the most productive and ecologically diverse fishing regions in North America. Species here span three overlapping systems:

- **Freshwater / swamp:** cypress-lined bayous, oxbow lakes, atchafalaya basin backwaters
- **Brackish marsh:** estuary and tidal flat species that tolerate salinity swings
- **Nearshore Gulf:** shallow Gulf waters accessible from the barrier islands and passes

Notable Louisiana-specific common names (e.g., *Sacalait*, *Choupique*, *Goggle-eye*) should be used as the `common` field where they are the dominant local usage, with a flavor note explaining the regional name.

## Target Species

The following species are the primary candidates for this batch. Each must be added as a complete `fish.json` entry per the schema in Spec 04.

### Common (EXP 15–40)

| Common Name | Scientific Name | Habitat | Notes |
|---|---|---|---|
| Sacalait (White Crappie) | *Pomoxis annularis* | freshwater | "Sacalait" is the Cajun French name; dominant local usage |
| Bluegill | *Lepomis macrochirus* | freshwater | Ubiquitous in bayous and farm ponds |
| Channel Catfish | *Ictalurus punctatus* | freshwater | Most-caught catfish species in LA |
| Blue Catfish | *Ictalurus furcatus* | freshwater | Larger cousin; common in the Atchafalaya |
| Largemouth Bass | *Micropterus salmoides* | freshwater | Premier sport fish of Louisiana swamps |
| Spotted Bass | *Micropterus punctulatus* | freshwater | Common alongside largemouth |
| Goggle-eye (Warmouth) | *Lepomis gulosus* | freshwater | "Goggle-eye" is the near-universal Louisiana name |
| Yellow Bass | *Morone mississippiensis* | freshwater | Native to the Mississippi basin |
| Atlantic Croaker | *Micropogonias undulatus* | brackish | Bread-and-butter inshore species |
| Gulf Menhaden | *Brevoortia patronus* | saltwater | Massive schools; important baitfish |

### Uncommon (EXP 45–80)

| Common Name | Scientific Name | Habitat | Notes |
|---|---|---|---|
| Spotted Seatrout | *Cynoscion nebulosus* | brackish | "Speckled trout" locally; most-targeted inshore fish in LA |
| Red Drum | *Sciaenops ocellatus* | brackish | "Redfish" locally; iconic marsh species |
| Black Drum | *Pogonias cromis* | brackish | Large inshore drum; targeted near oyster reefs |
| Sheepshead | *Archosargus probatocephalus* | brackish | Notorious bait-stealer; found around pilings |
| Flounder (Gulf) | *Paralichthys albigutta* | brackish | Flatfish ambush predator; gigged at night in passes |
| Striped Mullet | *Mugil cephalus* | brackish | Culturally important; both baitfish and food fish |
| Bowfin (Choupique) | *Amia calva* | freshwater | "Choupique" is the Cajun name; a living fossil |
| Longnose Gar | *Lepisosteus osseus* | freshwater | Prehistoric; cruises the surface of cypress swamps |
| Tripletail | *Lobotes surinamensis* | saltwater | Distinctive; floats near crab trap buoys and structure |
| Pompano | *Trachinotus carolinus* | saltwater | Prized table fish; seasonal in passes |

### Rare (EXP 90–150)

| Common Name | Scientific Name | Habitat | Notes |
|---|---|---|---|
| Cobia | *Rachycentron canadum* | saltwater | Strong, fast; follows rays and turtles inshore |
| Tarpon | *Megalops atlanticus* | saltwater | "Silver King"; legendary sport fish in Gulf passes |
| Spotted Gar | *Lepisosteus oculatus* | freshwater | More heavily spotted than longnose; marsh specialist |
| Alligator Gar | *Atractosteus spatula* | freshwater | Can exceed 8 feet; ancient apex predator of the basin |
| Spanish Mackerel | *Scomberomorus maculatus* | saltwater | Fast, schooling; arrives with spring warming |
| King Mackerel | *Scomberomorus cavalla* | saltwater | Nearshore Gulf; large specimens are a trophy |

### Legendary (EXP 175–250)

| Common Name | Scientific Name | Habitat | Notes |
|---|---|---|---|
| Gulf Sturgeon | *Acipenser oxyrinchus desotoi* | brackish | Federally threatened; a true relic; runs the Pearl and Pascagoula |
| Atlantic Tarpon (Giant) | *Megalops atlanticus* | saltwater | 100+ lb specimen; once-in-a-lifetime catch in the Gulf |

## ASCII Art Guidelines (Louisiana-specific)

Follow the general guidelines in Spec 04. Additional notes for this batch:

- Gar species: elongated snout should be represented — e.g., `--><(((º>` or `>--(((º>`
- Flatfish (flounder): consider a flattened motif — e.g., `><[[[º>`
- Drum species (redfish, black drum, croaker): a round-bodied motif works — e.g., `><(((*>`
- Bowfin (choupique): a stubby, blunt-headed shape — e.g., `>((({º>`

## Habitat Values

Use existing habitat values from Spec 04. Louisiana species map as follows:

| Louisiana system | `habitat` value |
|---|---|
| Cypress swamp, bayou, Atchafalaya basin | `freshwater` |
| Coastal marsh, estuary, tidal pass | `brackish` |
| Nearshore Gulf, barrier island passes | `saltwater` |

## Integration Notes

- These entries are additive — they join the existing `fish.json` pool and are subject to the same weighted catch probability defined in [Spec 03](./03-catch-probability.md).
- Regional flavor is conveyed through local common names and `flavor` text; no new schema fields are needed.
- The total species count after this batch (~28 new entries) should move the pool significantly toward the 100-entry target in Spec 04.

## Color Guidelines

Each entry requires a `color` field: an ANSI 256-color integer (0–255) representing the fish's most visually distinctive hue. General guidance for this batch:

- Redfish / Red Drum: deep red-orange (e.g., 166, 160)
- Speckled Trout: silver-grey with spots (e.g., 250, 102)
- Sheepshead: grey with black vertical bars (e.g., 240)
- Flounder: sandy brown (e.g., 136, 130)
- Gar species: olive-green (e.g., 58, 64)
- Bowfin (Choupique): dark olive/brown (e.g., 58)
- Catfish: blue-grey (e.g., 67, 103)
- Sacalait / Crappie: silver-olive (e.g., 144)
- Bluegill: blue-teal with orange breast (e.g., 31, 74)
- Tarpon: bright silver (e.g., 188, 252)
- Pompano: silver-yellow (e.g., 229, 220)
- Tripletail: mottled brown (e.g., 94, 130)

See the [Spec 04 color guidelines](./04-fish-database.md#color-guidelines) and the ANSI 256-color chart for exact values.

## Acceptance Criteria

- [x] All entries from the target species table are present in `fish.json`.
- [x] Each entry passes Spec 04 schema validation (all required fields including `color`, unique `id`, ascii ≤ 22 chars).
- [x] Every `color` value is an integer in the range 0–255.
- [x] EXP values fall within the correct rarity tier range (Spec 04 / Spec 08).
- [x] Cajun/regional common names include a `flavor` sentence that explains the local name or cultural context.
- [x] Habitat values are one of the six valid values from Spec 04.
- [x] No fictional species; all entries are real, verifiable fish found in Southeast Louisiana.
