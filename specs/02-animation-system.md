# Spec 02 — Animation System

**Status:** `TODO`
**Depends on:** [04 Fish Database](./04-fish-database.md)

---

## Purpose

Defines the ASCII art frames and sequencing logic for the fisherman overlay. All visual output is handled here.

## Frame States

### 1. Idle
The fisherman stands at the water's edge, line in the water. This is the default state between turns.

```
     |
     |
 \o/ |
  |  ~
 / \ ~~~
```

Rendered statically — no looping animation in idle to avoid terminal noise.

### 2. Hooking
Triggered immediately when a catch is rolled. Line goes taut. Display for ~1 second (or 1 render cycle).

```
     !!
     |/
 \o/ |
  |  *<
 / \ ~~~
```

### 3. Retrieving
Animated: cycle 2–3 frames showing the reel-in motion. Each frame held for ~0.5 seconds.

```
Frame A        Frame B
   \               |
    \|             |/
\o/ |          \o/ |
 |  ~<          |  ~<
/ \  ~~        / \  ~~
```

### 4. Display (Catch Reveal)
Fisherman holds up the caught fish. This frame includes the fish's ASCII art and name. Held for ~3 seconds before returning to idle.

```
  \o/  ><(((º>
   |   Atlantic Bluefin Tuna
  / \
```

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
