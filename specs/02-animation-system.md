# Spec 02 — Animation System

**Status:** `TODO`
**Depends on:** [04 Fish Database](./04-fish-database.md)

---

## Purpose

Defines the ASCII art frames and sequencing logic for the fisherman overlay. All visual output is handled here.

## Frame States

All frames share the same bounding box: **8 rows tall, ~22 columns wide**. Characters must stay in the same position across all four states so transitions look like pose changes, not redraws.

### 1. Idle
The fisherman stands at the water's edge, rod extended, line dropped into the water. This is the default state between turns.

```
          |
   _     /|
  (o)   / |
   \>--'  |
   /\   ~~|
  /  \~~~~|
      ~~~~~
      *
```

- Row 1: bare fishing line hanging from rod tip
- Rows 2–3: head and rod arm (rod angled up-right with `/`)
- Row 4: torso leaning into cast (`\>--'` connects body to rod)
- Rows 5–6: legs with water surface rising behind them
- Row 7: deeper water
- Row 8: lure/bobber (`*`) resting at depth

Rendered statically — no looping animation in idle to avoid terminal noise.

### 2. Hooking
Triggered immediately when a catch is rolled. Line snaps taut and horizontal. Display for ~1 second (or 1 render cycle).

```
  !!
   _     /
  (!)   /
   \>--/
   /\  ----*
  /  \~~~~~
      ~~~~~~
```

- `!!` above head signals the strike
- Head changes to `(!)` (eyes wide, startled)
- Rod bends: `/` goes steeper (fish pulling down and away)
- Line goes horizontal: `----*` shows the taut line with fish at end
- Water unchanged — fish is below surface, just hooked

### 3. Retrieving
Animated: 2–3 frames showing the reel-in motion. Each frame held for ~0.5 seconds. Fish (`><`) rises toward the surface between frames.

```
Frame A (fish deep, line still taut):   Frame B (fish at surface, reel almost done):

   _     /                                 _     /
  (o)   /|                                (o)  =/
   \>--' |                                 \>--'
   /\  ><|                                 /\  ><~
  /  \~~~|                                /  \~~~~
      ~~~~~                                   ~~~~~
```

- Frame A: `><` fish symbol appears at bottom of taut line (`><|`)
- Frame B: `=` on rod shows reel tension; fish at surface (`><~`) with wake
- The fisherman's expression returns to `(o)` — focused, not panicked
- Body posture stays consistent; only line angle and fish position change

### 4. Display (Catch Reveal)
Fisherman raises both arms to hold the catch overhead. Fish ASCII art and name rendered to the right. Held for ~3 seconds before returning to idle.

```
  \(o)/  ><(((o>
   _|_   Bluefin Tuna
   )|(
   /\   ~~|
  /  \~~~~|
      ~~~~~
```

- Arms raised: `\(o)/` instead of the normal rod-holding pose
- Fish art (`><(((o>`) appears directly to the right of the raised hands
- Fish name on the line below, aligned with the art
- `)|( ` for the torso — same narrow waist as the idle/hooking poses, not a wide body shape
- Water column (`~~|`, `~~~~|`) stays on the right at the same position as all other frames — the fisherman is still standing at the bank, not out at sea

The fish ASCII art is loaded from the fish database entry (see [Spec 04](./04-fish-database.md)). Each fish has its own art embedded in the database.

## Sequencing

```
Idle → (10% roll hits) → Hooking (1s) → Retrieving (1–1.5s) → Display (3s) → Idle
```

## Rendering Rules

- All frames are drawn at a fixed terminal column offset (rightmost ~30 cols).
- Use ANSI `\x1b[{row};{col}H` cursor positioning for each line of a frame.
- After drawing, reset cursor to its original position so Claude's output is unaffected.
- Save/restore cursor position with `\x1b[s` / `\x1b[u` around each render call.
- Clear the previous frame before drawing the next using targeted line clears (`\x1b[2K` at each row used by the fisherman).

## Acceptance Criteria

- [ ] All four frame states render correctly at the far right.
- [ ] Frame transitions play in the correct order.
- [ ] No cursor artifacts remain after each render cycle.
- [ ] Display frame correctly injects the fish name and ASCII art from the database.
- [ ] Rendering is a no-op when terminal width < 120 columns.
