# Fish Catalog

**Tags:** fish, catalog, reference, rarity, habitat, species

**Source data:** `.claude/commands/gone-fishing/fish.json` — 119 entries as of current implementation.

Complete reference table of every catchable species in the pool, organized by rarity tier (Legendary → Rare → Uncommon → Common) and sorted within each tier by habitat then EXP descending. Use this article as a lookup table. For schema details see [[fish-database]]. For how rarity and habitat affect catch likelihood see [[catch-probability]]. For EXP tier ranges and level progression see [[leveling-system]].

## Summary: Counts by Rarity

| Rarity | Count | EXP Range |
|---|---|---|
| Legendary | 5 | 200–250 |
| Rare | 16 | 95–140 |
| Uncommon | 37 | 48–80 |
| Common | 61 | 15–38 |
| **Total** | **119** | — |

## Summary: Counts by Habitat

| Habitat | Legendary | Rare | Uncommon | Common | Total |
|---|---|---|---|---|---|
| `freshwater` | 0 | 6 | 6 | 27 | 39 |
| `saltwater` | 1 | 5 | 17 | 19 | 42 |
| `brackish` | 2 | 1 | 5 | 6 | 14 |
| `deep-sea` | 2 | 3 | 4 | 3 | 12 |
| `tropical` | 0 | 1 | 5 | 4 | 10 |
| `arctic` | 0 | 0 | 0 | 2 | 2 |
| **Total** | **5** | **16** | **37** | **61** | **119** |

---

## Legendary (5 species)

Base weight: 3. See [[catch-probability]] for time-of-day multipliers up to ×2.5 at night.

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `beluga-sturgeon` | Beluga Sturgeon | *Huso huso* | brackish | 230 | `>=====(((º>` | 247 |
| `gulf-sturgeon` | Gulf Sturgeon | *Acipenser oxyrinchus desotoi* | brackish | 200 | `>==(((º>` | 241 |
| `coelacanth` | Coelacanth | *Latimeria chalumnae* | deep-sea | 250 | `><{{{{{º>` | 25 |
| `oarfish` | Giant Oarfish | *Regalecus glesne* | deep-sea | 220 | `>---===---º>` | 189 |
| `atlantic-tarpon` | Atlantic Tarpon | *Megalops atlanticus* | saltwater | 210 | `><((((((((º>` | 188 |

---

## Rare (16 species)

Base weight: 12. Roughly 12% pull share before modifiers.

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `atlantic-sturgeon` | Atlantic Sturgeon | *Acipenser oxyrinchus* | brackish | 115 | `>===((º>` | 241 |
| `anglerfish` | Deep-Sea Anglerfish | *Melanocetus johnsonii* | deep-sea | 125 | `>|{((º>` | 232 |
| `gulper-eel` | Pelican Gulper Eel | *Eurypharynx pelecanoides* | deep-sea | 115 | `>((((((~>` | 236 |
| `blobfish` | Blobfish | *Psychrolutes marcidus* | deep-sea | 110 | `>~(( º>` | 218 |
| `taimen` | Siberian Taimen | *Hucho taimen* | freshwater | 140 | `>---(((º>` | 136 |
| `arapaima` | Arapaima | *Arapaima gigas* | freshwater | 135 | `><(((((º>` | 28 |
| `alligator-gar` | Alligator Gar | *Atractosteus spatula* | freshwater | 130 | `>=====(º>` | 58 |
| `dorado` | Golden Dorado | *Salminus brasiliensis* | freshwater | 125 | `><{{{(º>` | 220 |
| `lake-sturgeon` | Lake Sturgeon | *Acipenser fulvescens* | freshwater | 120 | `>===(((º>` | 241 |
| `spotted-gar` | Spotted Gar | *Lepisosteus oculatus* | freshwater | 95 | `>---(º>` | 64 |
| `blue-marlin` | Blue Marlin | *Makaira nigricans* | saltwater | 140 | `>----(((º>` | 27 |
| `swordfish` | Swordfish | *Xiphias gladius* | saltwater | 130 | `>-----(º>` | 32 |
| `atlantic-bluefin-tuna` | Atlantic Bluefin Tuna | *Thunnus thynnus* | saltwater | 120 | `><(((((º>` | 21 |
| `king-mackerel` | King Mackerel | *Scomberomorus cavalla* | saltwater | 110 | `>~(((·º>` | 32 |
| `spanish-mackerel` | Spanish Mackerel | *Scomberomorus maculatus* | saltwater | 100 | `>~((·º>` | 33 |
| `giant-moray` | Giant Moray | *Gymnothorax javanicus* | tropical | 110 | `~~~~(º>` | 34 |

---

## Uncommon (37 species)

Base weight: 25. Roughly 25% pull share before modifiers.

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `tarpon` | Tarpon | *Megalops atlanticus* | brackish | 78 | `><((((º>` | 255 |
| `red-drum` | Red Drum | *Sciaenops ocellatus* | brackish | 60 | `><(((·º>` | 166 |
| `black-drum` | Black Drum | *Pogonias cromis* | brackish | 55 | `><)))º>` | 236 |
| `striped-mullet` | Striped Mullet | *Mugil cephalus* | brackish | 52 | `><((·º>` | 250 |
| `gulf-flounder` | Gulf Flounder | *Paralichthys albigutta* | brackish | 50 | `~><(º>` | 136 |
| `dragonfish` | Pacific Blackdragon | *Idiacanthus antrostomus* | deep-sea | 72 | `>~|||(º>` | 232 |
| `viperfish` | Sloane's Viperfish | *Chauliodus sloani* | deep-sea | 70 | `>|||(º>` | 237 |
| `fangtooth` | Common Fangtooth | *Anoplogaster cornuta* | deep-sea | 68 | `>|(|(º>` | 232 |
| `barreleye` | Barreleye Fish | *Macropinna microstoma* | deep-sea | 65 | `Ö><(º>` | 57 |
| `paddlefish` | American Paddlefish | *Polyodon spathula* | freshwater | 80 | `>----(º>` | 247 |
| `muskellunge` | Muskellunge | *Esox masquinongy* | freshwater | 75 | `>---((º>` | 58 |
| `chinook-salmon` | Chinook Salmon | *Oncorhynchus tshawytscha* | freshwater | 70 | `><((((º>` | 208 |
| `steelhead` | Steelhead | *Oncorhynchus mykiss irideus* | freshwater | 60 | `><(((º>` | 74 |
| `lake-trout` | Lake Trout | *Salvelinus namaycush* | freshwater | 55 | `><(((º>` | 240 |
| `bowfin` | Bowfin | *Amia calva* | freshwater | 50 | `>~((((º>` | 58 |
| `wahoo` | Wahoo | *Acanthocybium solandri* | saltwater | 75 | `>--(((º>` | 33 |
| `roosterfish` | Roosterfish | *Nematistius pectoralis* | saltwater | 75 | `><||(((º>` | 244 |
| `giant-trevally` | Giant Trevally | *Caranx ignobilis* | saltwater | 72 | `><{((º>` | 248 |
| `mahi-mahi` | Mahi-Mahi | *Coryphaena hippurus* | saltwater | 70 | `><{((º>` | 46 |
| `permit` | Permit | *Trachinotus falcatus* | saltwater | 70 | `><((º>` | 253 |
| `atlantic-halibut` | Atlantic Halibut | *Hippoglossus hippoglossus* | saltwater | 68 | `~>((((º>` | 130 |
| `yellowfin-tuna` | Yellowfin Tuna | *Thunnus albacares* | saltwater | 65 | `><((((º>` | 27 |
| `cobia` | Cobia | *Rachycentron canadum* | saltwater | 65 | `>-(((º>` | 94 |
| `bonefish` | Bonefish | *Albula vulpes* | saltwater | 65 | `>--(º>` | 255 |
| `lingcod` | Lingcod | *Ophiodon elongatus* | saltwater | 62 | `>~(((º>` | 64 |
| `amberjack` | Greater Amberjack | *Seriola dumerili* | saltwater | 60 | `><(((|º>` | 178 |
| `barracuda` | Great Barracuda | *Sphyraena barracuda* | saltwater | 60 | `>----(º>` | 252 |
| `tripletail` | Tripletail | *Lobotes surinamensis* | saltwater | 60 | `><}}º>` | 94 |
| `sablefish` | Sablefish | *Anoplopoma fimbria* | saltwater | 58 | `><(((º>` | 238 |
| `redfish` | Red Drum | *Sciaenops ocellatus* | saltwater | 55 | `><(((·º>` | 166 |
| `grouper` | Red Grouper | *Epinephelus morio* | saltwater | 55 | `><{{{º>` | 160 |
| `jack-crevalle` | Jack Crevalle | *Caranx hippos* | saltwater | 55 | `><{(º>` | 142 |
| `wrasse` | Napoleon Wrasse | *Cheilinus undulatus* | tropical | 65 | `><{(º>` | 33 |
| `moray-eel` | Green Moray Eel | *Gymnothorax funebris* | tropical | 60 | `~~~(º>` | 34 |
| `lionfish` | Red Lionfish | *Pterois volitans* | tropical | 55 | `><|||º>` | 196 |
| `triggerfish` | Queen Triggerfish | *Balistes vetula* | tropical | 50 | `><{|º>` | 51 |
| `pufferfish` | Porcupine Pufferfish | *Diodon hystrix* | tropical | 48 | `O><(º>` | 136 |

---

## Common (61 species)

Base weight: 60. Roughly 60% pull share before modifiers. Most accessible rarity; broadest habitat coverage.

### Arctic (2)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `arctic-char` | Arctic Char | *Salvelinus alpinus* | arctic | 35 | `><(((º>` | 209 |
| `capelin` | Capelin | *Mallotus villosus* | arctic | 15 | `><(º>` | 252 |

### Brackish (6)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `striped-bass` | Striped Bass | *Morone saxatilis* | brackish | 38 | `><|||º>` | 252 |
| `common-snook` | Common Snook | *Centropomus undecimalis* | brackish | 36 | `>-((|º>` | 252 |
| `sheepshead` | Sheepshead | *Archosargus probatocephalus* | brackish | 30 | `><||º>` | 251 |
| `spotted-seatrout` | Spotted Seatrout | *Cynoscion nebulosus* | brackish | 28 | `><(·(º>` | 255 |
| `atlantic-croaker` | Atlantic Croaker | *Micropogonias undulatus* | brackish | 22 | `><((·º>` | 214 |
| `mullet` | Striped Mullet | *Mugil cephalus* | brackish | 18 | `><(((º>` | 248 |

### Deep-Sea (3)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `rattail` | Grenadier Rattail | *Coryphaenoides rupestris* | deep-sea | 38 | `><((~>` | 238 |
| `lanternfish` | Myctophid Lanternfish | *Myctophum punctatum* | deep-sea | 35 | `·><(º>` | 57 |
| `bristlemouth` | Bristlemouth | *Cyclothone microdon* | deep-sea | 32 | `>||||(º>` | 237 |

### Freshwater (27)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `northern-pike` | Northern Pike | *Esox lucius* | freshwater | 38 | `>---(º>` | 34 |
| `largemouth-bass` | Largemouth Bass | *Micropterus salmoides* | freshwater | 35 | `><{{{º>` | 64 |
| `walleye` | Walleye | *Sander vitreus* | freshwater | 35 | `><(((^>` | 180 |
| `longnose-gar` | Longnose Gar | *Lepisosteus osseus* | freshwater | 35 | `>-----(º>` | 58 |
| `smallmouth-bass` | Smallmouth Bass | *Micropterus dolomieu* | freshwater | 32 | `><{((º>` | 130 |
| `rainbow-trout` | Rainbow Trout | *Oncorhynchus mykiss* | freshwater | 30 | `><(((º>` | 75 |
| `brook-trout` | Brook Trout | *Salvelinus fontinalis* | freshwater | 28 | `><(((º>` | 65 |
| `spotted-bass` | Spotted Bass | *Micropterus punctulatus* | freshwater | 28 | `><{(º>` | 70 |
| `blue-catfish` | Blue Catfish | *Ictalurus furcatus* | freshwater | 28 | `>~(((º>` | 67 |
| `channel-catfish` | Channel Catfish | *Ictalurus punctatus* | freshwater | 25 | `>~(((º>` | 243 |
| `sauger` | Sauger | *Sander canadensis* | freshwater | 25 | `><((^>` | 136 |
| `white-bass` | White Bass | *Morone chrysops* | freshwater | 22 | `><(|º>` | 255 |
| `grass-carp` | Grass Carp | *Ctenopharyngodon idella* | freshwater | 22 | `><)))º>` | 251 |
| `yellow-perch` | Yellow Perch | *Perca flavescens* | freshwater | 20 | `><((|º>` | 220 |
| `common-carp` | Common Carp | *Cyprinus carpio* | freshwater | 20 | `><)))º>` | 178 |
| `freshwater-drum` | Freshwater Drum | *Aplodinotus grunniens* | freshwater | 20 | `><))º>` | 252 |
| `tilapia` | Nile Tilapia | *Oreochromis niloticus* | freshwater | 20 | `><((|º>` | 248 |
| `yellow-bass` | Yellow Bass | *Morone mississippiensis* | freshwater | 20 | `><(||º>` | 226 |
| `crappie` | Black Crappie | *Pomoxis nigromaculatus* | freshwater | 18 | `><((º>` | 240 |
| `brown-bullhead` | Brown Bullhead | *Ameiurus nebulosus* | freshwater | 18 | `>~((º>` | 94 |
| `white-crappie` | White Crappie | *Pomoxis annularis* | freshwater | 18 | `><((º>` | 251 |
| `redear-sunfish` | Redear Sunfish | *Lepomis microlophus* | freshwater | 17 | `><((º>` | 148 |
| `rock-bass` | Rock Bass | *Ambloplites rupestris* | freshwater | 16 | `><(º>` | 130 |
| `warmouth` | Warmouth | *Lepomis gulosus* | freshwater | 16 | `><((º>` | 94 |
| `bluegill` | Bluegill | *Lepomis macrochirus* | freshwater | 15 | `><((º>` | 148 |
| `pumpkinseed` | Pumpkinseed | *Lepomis gibbosus* | freshwater | 15 | `><((º>` | 214 |
| `golden-shiner` | Golden Shiner | *Notemigonus crysoleucas* | freshwater | 15 | `><(º>` | 220 |

### Saltwater (19)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `ocean-sunfish` | Ocean Sunfish | *Mola mola* | saltwater | 35 | `O>(º>` | 250 |
| `red-snapper` | Red Snapper | *Lutjanus campechanus* | saltwater | 32 | `><(((º>` | 196 |
| `atlantic-cod` | Atlantic Cod | *Gadus morhua* | saltwater | 30 | `><(((º>` | 144 |
| `bluefish` | Bluefish | *Pomatomus saltatrix* | saltwater | 30 | `>~(((º>` | 39 |
| `sea-bass` | Black Sea Bass | *Centropristis striata* | saltwater | 28 | `><(((º>` | 24 |
| `pompano` | Florida Pompano | *Trachinotus carolinus* | saltwater | 28 | `><((º>` | 220 |
| `flounder` | Summer Flounder | *Paralichthys dentatus* | saltwater | 25 | `~><(º>` | 130 |
| `haddock` | Haddock | *Melanogrammus aeglefinus* | saltwater | 25 | `><(((º>` | 244 |
| `weakfish` | Weakfish | *Cynoscion regalis* | saltwater | 24 | `>~((º>` | 251 |
| `atlantic-mackerel` | Atlantic Mackerel | *Scomber scombrus* | saltwater | 22 | `>~((º>` | 33 |
| `pollock` | Pollock | *Pollachius virens* | saltwater | 22 | `><(((º>` | 58 |
| `sand-perch` | Sand Perch | *Diplectrum formosum* | saltwater | 17 | `><(|º>` | 137 |
| `sculpin` | Staghorn Sculpin | *Leptocottus armatus* | saltwater | 16 | `>{{(º>` | 94 |
| `spot` | Spot | *Leiostomus xanthurus* | saltwater | 15 | `><(º>` | 250 |
| `atlantic-herring` | Atlantic Herring | *Clupea harengus* | saltwater | 15 | `><(º>` | 252 |
| `sprat` | European Sprat | *Sprattus sprattus* | saltwater | 15 | `><(º>` | 252 |
| `pinfish` | Pinfish | *Lagodon rhomboides* | saltwater | 15 | `><(º>` | 114 |
| `pacific-herring` | Pacific Herring | *Clupea pallasii* | saltwater | 15 | `><(º>` | 252 |
| `gulf-menhaden` | Gulf Menhaden | *Brevoortia patronus* | saltwater | 15 | `><(º>` | 248 |

### Tropical (4)

| id | common | scientific | habitat | exp | ascii | color |
|---|---|---|---|---|---|---|
| `clownfish` | Ocellaris Clownfish | *Amphiprion ocellaris* | tropical | 20 | `><|º>` | 208 |
| `sergeant-major` | Sergeant Major | *Abudefduf saxatilis* | tropical | 18 | `><||(º>` | 226 |
| `damselfish` | Yellowtail Damselfish | *Microspathodon chrysurus* | tropical | 16 | `><(º>` | 27 |
| `goby` | Banded Goby | *Amblygobius phalaena* | tropical | 15 | `><(º>` | 130 |

---

## Notes on the Data

**Deep-sea habitat** has no seasonal modifier (×1.0 for all seasons) — the only habitat unaffected by the calendar. Arctic peaks heavily in winter (×1.8) and is suppressed in summer (×0.3). Tropical peaks in summer (×1.5) and is nearly absent in winter (×0.4). See [[catch-probability]] for the full multiplier table.

**EXP band separation:** The common ceiling is 38 EXP and the uncommon floor is 48 EXP — no overlap. This means a catch's rarity label reliably predicts its EXP contribution. See [[leveling-system]] for cumulative thresholds.

**Duplicate species notes:** `redfish` (saltwater, uncommon) and `red-drum` (brackish, uncommon) share the same scientific name (*Sciaenops ocellatus*), representing the same species in different habitat contexts. Similarly, `mullet` (brackish, common) and `striped-mullet` (brackish, uncommon) both represent *Mugil cephalus* — the common entry is the standard stock; the uncommon is from the Southeast Louisiana regional batch (Spec 09). `tarpon` (brackish, uncommon) and `atlantic-tarpon` (saltwater, legendary) represent the same species at different size/lifecycle stages.

## Related

- [[fish-database]] — entry schema, ASCII art and color guidelines, rarity distribution targets
- [[catch-probability]] — base weights, time-of-day multipliers, seasonal habitat multipliers
- [[leveling-system]] — EXP tier ranges, cumulative threshold formula
