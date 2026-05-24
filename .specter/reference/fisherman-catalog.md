# Fisherman Catalog

**Tags:** fishermen, catalog, reference, roster, characters, backstory

**Source data:** `.claude/commands/gone-fishing/fishermen.json` — 8 entries implemented as of current build. Target roster size is 40. See [[fisherman-roster]] for the full schema, frame dimension rules, and visual differentiation constraints.

Complete reference of every implemented fisherman character: full backstory, type, and implementation notes. For character selection logic see [[gone-fishing-command]]. For re-rolling see [[skill-new-fisherman]].

## Roster Status

| Implemented | Target | Remaining |
|---|---|---|
| 8 | 40 | 32 |

All 8 currently implemented characters are `human` type. No `fantasy` type characters have been implemented yet.

---

## Characters

### grizzled-pete — Grizzled Pete

| Field | Value |
|---|---|
| Type | `human` |
| Region | Lake Superior, Great Lakes |
| Source | Core roster (original implementation) |

Pete spent forty years on Lake Superior before his boat sank in a storm he swears he predicted. He fishes now not for sport or food, because standing still makes his knees ache and the water doesn't ask questions. His tackle box holds more memories than lures, and his thermos has never once contained coffee.

Grizzled Pete is the canonical reference implementation. All subsequent characters are validated against his frame dimensions. He is the first character assigned on `/gone-fishing` if selected by the random draw.

---

### jean-pierre-boudreaux — Jean-Pierre Boudreaux

| Field | Value |
|---|---|
| Type | `human` |
| Region | Southeast Louisiana / Atchafalaya Basin |
| Source | Spec 10 (Regional Fishermen batch) |

Raised on the Atchafalaya, Jean-Pierre spent his first thirty years running a crawfish trap line before his back gave out and he switched to rod fishing in the cypress bayous. He fishes from a battered aluminum pirogue and refuses to use anything but live shrimp for bait. His wide straw hat has survived a dozen gulf storms, and his thermos always holds café au lait, never coffee.

---

### marisol-cayo — Marisol Cayo

| Field | Value |
|---|---|
| Type | `human` |
| Region | Florida Keys (Lower Keys flats) |
| Source | Spec 10 (Regional Fishermen batch) |

Marisol grew up watching her father pole skiffs across the flats of the Lower Keys before she was old enough to hold a rod. She guides full-time now, specializing in permit and bonefish, and has a reputation for spotting tailing fish before anyone else on the boat. She keeps a push-pole in her left hand and a fly rod in her right and considers a skiff engine a last resort.

---

### kodiak-karl — Kodiak Karl

| Field | Value |
|---|---|
| Type | `human` |
| Region | Bristol Bay / Kodiak Island, Alaska |
| Source | Spec 10 (Regional Fishermen batch) |

Karl worked deckhand on a Bristol Bay salmon seiner for twelve years before buying his own 32-foot boat and running it solo. He fishes Chinook in the summer and Dungeness in the fall, and once stayed awake for forty-one consecutive hours during a good king salmon run without missing a set. His hands are permanently shaped around a rod or a coffee mug, and he sees no meaningful difference between the two.

---

### pacific-ray — Pacific Ray

| Field | Value |
|---|---|
| Type | `human` |
| Region | Santa Cruz coast, California |
| Source | Spec 10 (Regional Fishermen batch) |

Ray has fished the same stretch of beach north of Santa Cruz for thirty years, casting for striped bass and halibut at dawn while the surfers are still waxing their boards. His rod is twelve feet long and he once cast so far that a pelican intercepted the bait before it hit the water. He fishes in board shorts year-round and has never owned waders.

---

### big-muddy-delphine — Big Muddy Delphine

| Field | Value |
|---|---|
| Type | `human` |
| Region | Mississippi River |
| Source | Spec 10 (Regional Fishermen batch) |

Delphine has been catfishing the Mississippi River since she was six years old and her daddy first put a cane pole in her hands. She prefers noodling but keeps a rod for when the water is cold and the catfish are deep. Her personal best flathead weighed seventy-three pounds, and she landed it alone in a johnboat in the dark without a net.

---

### bazza-gilhooly — Bazza Gilhooly

| Field | Value |
|---|---|
| Type | `human` |
| Region | Cairns region, Queensland, Australia |
| Source | Spec 10 (Regional Fishermen batch) |

Bazza fishes the tidal flats and mangrove creeks north of Cairns for barramundi, which he describes as the best eating fish on the planet and says so to anyone who'll listen. He wears a cork hat regardless of weather, keeps one eye on his lure and one eye out for saltwater crocodiles, and has named every significant snag in a fifty-kilometer stretch of river. His ute has more rod holders than seats.

---

### pieter-van-der-meer — Pieter van der Meer

| Field | Value |
|---|---|
| Type | `human` |
| Region | Prinsengracht canal, Amsterdam, Netherlands |
| Source | Spec 10 (Regional Fishermen batch) |

Pieter has fished the Prinsengracht canal since his grandfather taught him at age four, using a simple pole over the railing of a houseboat. He targets bream and perch in the city canals, wears a waxed cotton jacket regardless of season, and considers the rumble of passing canal boats an acceptable form of white noise. He keeps stroopwafels in his tackle box where other anglers keep lures, and offers one to any passerby who stops to watch.

---

## Visual Differentiation Summary

No two `idle` frames in the implemented set are identical. Key distinguishing features:

| id | Head | Body/Stance | Base/Setting | Rod Style |
|---|---|---|---|---|
| `grizzled-pete` | `\o/` upright | standard legs | water's edge | straight up |
| `jean-pierre-boudreaux` | `(o)` with hat `_\|_` | standing in pirogue | pirogue hull `====` | straight up |
| `marisol-cayo` | `\o\|` dual-arm | two-rod stance | skiff hull `====` | fly rod + push-pole |
| `kodiak-karl` | `{O}` heavy | double legs `\|\|` | water's edge | straight up |
| `pacific-ray` | `\o/` angled | standard legs | beach open | 12-ft surf rod `/` |
| `big-muddy-delphine` | `(o)` round | standing in boat | johnboat `[=====]` | cane pole vertical |
| `bazza-gilhooly` | `\Ô/` cork hat row | standard legs | mangrove edge | standard with tilt |
| `pieter-van-der-meer` | `\|o\|` compact | railing lean `==\|==` | houseboat rail | drop-line vertical |

## Planned Characters (Spec 10, Not Yet Implemented)

Spec 10 specifies 7 regional characters; all 7 are now implemented. The remaining 32 characters (to reach the 40-character target) have no published spec as of current implementation. No `fantasy` type characters have been added yet.

## Related

- [[fisherman-roster]] — full entry schema, frame dimension table, `type` field rules, visual differentiation rules, backstory voice guide
- [[gone-fishing-command]] — how a character is assigned on first run
- [[skill-new-fisherman]] — re-rolling to a different character without resetting catch history
- [[persistence-layer]] — `profile.json` stores the active `fishermanId`
