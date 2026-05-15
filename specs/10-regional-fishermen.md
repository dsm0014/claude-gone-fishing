# Spec 10 — Regional Human Fishermen

**Status:** `TODO`
**Depends on:** [07 Fisherman Roster](./07-fisherman-roster.md)

---

## Purpose

Add 7 regionally grounded human fishermen to `fishermen.json`, each rooted in a specific fishing culture and geography. These entries fill slots in the 40-character human roster defined in Spec 07 and must be visually distinct from one another and from Grizzled Pete.

## Regions

| ID | Name | Region | Fishing Culture |
|---|---|---|---|
| `jean-pierre-boudreaux` | Jean-Pierre Boudreaux | Southeast Louisiana | Cajun bayou and marsh |
| `marisol-cayo` | Marisol Cayo | Florida Keys | Saltwater flats fishing |
| `kodiak-karl` | Kodiak Karl | Alaska | Commercial salmon fishing |
| `pacific-ray` | Pacific Ray | California | Surf casting |
| `big-muddy-delphine` | Big Muddy Delphine | Mississippi River | River catfishing |
| `bazza-gilhooly` | Bazza Gilhooly | Queensland, Australia | Barramundi in tidal creeks |
| `pieter-van-der-meer` | Pieter van der Meer | Amsterdam, Netherlands | Urban canal fishing |

---

## Character Definitions

### Jean-Pierre Boudreaux — Southeast Louisiana

**Type:** `human`

**Backstory:** Raised on the Atchafalaya, Jean-Pierre spent his first thirty years running a crawfish trap line before his back gave out and he switched to rod fishing in the cypress bayous. He fishes from a battered aluminum pirogue and refuses to use anything but live shrimp for bait. His wide straw hat has survived a dozen gulf storms, and his thermos always holds café au lait, never coffee.

**Distinguishing traits:** Wide straw hat, seated in a pirogue, rod resting off the bow.

**Draft frames:**
```
idle:        ["   |    ", "  _|_   ", " (o)  ~ ", "  |   ~~", " ====~~~"]
hooking:     ["  !!    ", "  _|/   ", " (o)  | ", "  |  *< ", " ====~~~"]
retrieving:  ["  \\    ", " (o) |/ ", "  |   ~<", " ====~~~"]
display:     [" (o)    ", "  |     ", " ====   "]
```
*`_|_` = hat brim over rod, `(o)` = face under hat, `====` = pirogue hull*

---

### Marisol Cayo — Florida Keys

**Type:** `human`

**Backstory:** Marisol grew up watching her father pole skiffs across the flats of the Lower Keys before she was old enough to hold a rod. She guides full-time now, specializing in permit and bonefish, and has a reputation for spotting tailing fish before anyone else on the boat. She keeps a push-pole in her left hand and a fly rod in her right and considers a skiff engine a last resort.

**Distinguishing traits:** Standing upright on a skiff platform, push-pole in off-hand, rod angled forward, polarized glasses.

**Draft frames:**
```
idle:        [" \\  |  ", "  \\o|  ", "   ||~  ", "   ||~~~", "  ====~~"]
hooking:     [" \\ !!  ", "  \\o|/ ", "   ||   ", "   || *<", "  ====~~"]
retrieving:  [" \\ \\  ", "  \\o|/ ", "   || ~<", "  ====~~"]
display:     ["  \\o/  ", "   ||   ", "  ====  "]
```
*Left `\\` = push-pole, right `|` = fishing rod, `====` = skiff deck*

---

### Kodiak Karl — Alaska

**Type:** `human`

**Backstory:** Karl worked deckhand on a Bristol Bay salmon seiner for twelve years before buying his own 32-foot boat and running it solo. He fishes Chinook in the summer and Dungeness in the fall, and once stayed awake for forty-one consecutive hours during a good king salmon run without missing a set. His hands are permanently shaped around a rod or a coffee mug, and he sees no meaningful difference between the two.

**Distinguishing traits:** Hunched posture, rain slicker hood, heavy-gauge rod, rubber waders deep in cold water.

**Draft frames:**
```
idle:        ["   |    ", "  _|_   ", " {O} ~  ", "  ||  ~~", "  ||  ~~"]
hooking:     ["  !!    ", "  _|/   ", " {O} |  ", "  || *< ", "  ||  ~~"]
retrieving:  ["   \\   ", " {O} |/ ", "  ||  ~<", "  ||  ~~"]
display:     [" {O}    ", "  ||    ", "  ||    "]
```
*`{O}` = hooded rain slicker head, `||` = heavy double-layer body/waders*

---

### Pacific Ray — California

**Type:** `human`

**Backstory:** Ray has fished the same stretch of beach north of Santa Cruz for thirty years, casting for striped bass and halibut at dawn while the surfers are still waxing their boards. His rod is twelve feet long and he once cast so far that a pelican intercepted the bait before it hit the water. He fishes in board shorts year-round and has never owned waders.

**Distinguishing traits:** Long surf-casting rod held at a low angle, wide open stance, bare feet in the sand, laid-back posture.

**Draft frames:**
```
idle:        ["       /", "      / ", " \\o/ ~ ", "  |   ~~", "  |   ~~"]
hooking:     ["     !! ", "      /!!", " \\o/ |  ", "  |  *< ", "  |   ~~"]
retrieving:  ["     \\  ", " \\o/ |/ ", "  |   ~<", "  |   ~~"]
display:     [" \\o/   ", "  |     ", "  |     "]
```
*Long `/` lines = 12-foot surf rod at low angle, wide planted-feet stance*

---

### Big Muddy Delphine — Mississippi River

**Type:** `human`

**Backstory:** Delphine has been catfishing the Mississippi River since she was six years old and her daddy first put a cane pole in her hands. She prefers noodling but keeps a rod for when the water is cold and the catfish are deep. Her personal best flathead weighed seventy-three pounds, and she landed it alone in a johnboat in the dark without a net.

**Distinguishing traits:** Cane pole (no reel), seated at the stern of a johnboat, overalls, unlit cigarette tucked behind one ear.

**Draft frames:**
```
idle:        [" |      ", " |      ", "(o)   ~ ", " |    ~~", "[=====]~"]
hooking:     ["!!      ", " |/     ", "(o)   | ", " |   *< ", "[=====]~"]
retrieving:  [" \\     ", "(o)  |/ ", " |    ~<", "[=====]~"]
display:     ["(o)     ", " |      ", "[=====] "]
```
*`(o)` = round head/face (no arms-out pose — cane pole held lower), `[=====]` = johnboat*

---

### Bazza Gilhooly — Queensland, Australia

**Type:** `human`

**Backstory:** Bazza fishes the tidal flats and mangrove creeks north of Cairns for barramundi, which he describes as the best eating fish on the planet and says so to anyone who'll listen. He wears a cork hat regardless of weather, keeps one eye on his lure and one eye out for saltwater crocodiles, and has named every significant snag in a fifty-kilometer stretch of river. His ute has more rod holders than seats.

**Distinguishing traits:** Cork hat with dangling corks, wide stance, tropical shirt, rod held low for underarm casting into mangrove gaps.

**Draft frames:**
```
idle:        ["*|*|*|* ", "   |    ", " \\Ô/ ~ ", "  |   ~~", " / \\ ~~"]
hooking:     ["*|*|*|* ", "   |/   ", " \\Ô/ | ", "  |  *< ", " / \\ ~~"]
retrieving:  ["*|*|*|* ", " \\Ô/|/ ", "  |   ~<", " / \\ ~~"]
display:     ["*|*|*|* ", " \\Ô/   ", " / \\   "]
```
*`*|*|*|*` = corks dangling from hat above head, `Ô` = round cork-hat brim on head*

---

### Pieter van der Meer — Amsterdam, Netherlands

**Type:** `human`

**Backstory:** Pieter has fished the Prinsengracht canal since his grandfather taught him at age four, using a simple pole over the railing of a houseboat. He targets bream and perch in the city canals, wears a waxed cotton jacket regardless of season, and considers the rumble of passing canal boats an acceptable form of white noise. He keeps stroopwafels in his tackle box where other anglers keep lures, and offers one to any passerby who stops to watch.

**Distinguishing traits:** Seated on a canal railing, legs dangling, very upright refined posture, short rod held straight down into the canal.

**Draft frames:**
```
idle:        ["   |    ", "   |    ", "  |o|~  ", " ==|==~~", "   |  ~~"]
hooking:     ["  !!    ", "   |/   ", "  |o||  ", " ==|==  ", "   | *< "]
retrieving:  ["   \\   ", "  |o||/ ", " ==|==~<", "   |  ~~"]
display:     ["  |o|   ", " ==|==  ", "   |    "]
```
*`|o|` = person at railing (upright, flanked by rails), `==|==` = canal railing/houseboat edge, line drops straight down*

---

## Schema

Each entry follows the `fishermen.json` schema from [Spec 07](./07-fisherman-roster.md):

```json
{
  "id": "jean-pierre-boudreaux",
  "name": "Jean-Pierre Boudreaux",
  "type": "human",
  "backstory": "...",
  "frames": {
    "idle":        ["...", "..."],
    "hooking":     ["...", "..."],
    "retrieving":  ["...", "..."],
    "display":     ["...", "..."]
  }
}
```

Frame rows must be equal-width strings (pad with spaces). Target width: 8 characters per row. Each frame array must have consistent row counts matching the other characters.

## Visual Differentiation Summary

| Character | Head | Stance | Rod Style | Base |
|---|---|---|---|---|
| Grizzled Pete *(ref)* | `\o/` bare | Standing | Straight up | Feet in water |
| Jean-Pierre | `(o)` wide hat | Seated | Resting off bow | Pirogue `====` |
| Marisol | `\o\|` + push-pole | Standing on platform | Forward angle | Skiff `====` |
| Kodiak Karl | `{O}` hood | Hunched | Straight up | Waders deep |
| Pacific Ray | `\o/` bare | Wide open | Long low angle `/` | Bare feet |
| Big Muddy Delphine | `(o)` no arms | Seated | Cane pole straight | Johnboat `[=]` |
| Bazza | `\Ô/` cork hat | Standing | Low underarm | Feet in water |
| Pieter | `\|o\|` railing | Seated, upright | Straight down | Canal railing |

---

## Acceptance Criteria

- [ ] All 7 entries are present in `fishermen.json` with all required fields (`id`, `name`, `type`, `backstory`, `frames`).
- [ ] Each backstory is 2–4 sentences and references the character's specific region and fishing style.
- [ ] All 7 idle frames are visually distinct from each other and from Grizzled Pete's idle frame.
- [ ] Frame rows within each character are equal-width strings.
- [ ] All frame arrays follow the four states: `idle`, `hooking`, `retrieving`, `display`.
- [ ] Characters appear in the random selection pool for `/gone-fishing` and `/new-fisherman`.
