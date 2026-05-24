# Animation System and Statusline Glyphs

**Tags:** animation, statusline, ANSI, glyphs, state

**Spec:** 02 — Status: DONE

All visual output for the minigame is delivered through the Claude Code statusline via a polling shell script (`statusline-command.sh`). There is no background animation process or separate terminal cursor management.

## Glyph States

The statusline displays the fisherman's name followed by a state glyph:

| Glyph | When |
|---|---|
| `~~~~~` | Profile exists but no active session (`activatedAt` older than 8 h or absent) |
| `~~*~~` | Session active, between turns. The `*` is colorized per the current rod tier (see [[leveling-system]]). |
| `~>!<~  <Name> <ascii>` | Fish caught and within the 120-second display window |

Example statusline in active state:

```
claude-sonnet-4-6 | ctx:12% | 🎣 Kodiak Karl  ~~*~~  Lv.7
```

On a catch:

```
claude-sonnet-4-6 | ctx:14% | 🎣 Kodiak Karl  ~>!<~  Bluefin Tuna ><(((°>  Lv.7
```

The level label `Lv.NN` and the lure glyph `*` share the same ANSI color for the current rod tier. The level label remains visible during the caught state.

## Fish Color Rendering

When a catch is displayed, the fish ASCII art is colorized using ANSI 256-color:

```sh
printf '\033[38;5;%sm%s\033[0m' "$fish_color" "$fish_ascii"
```

`fish_color` is the 256-color code stored in the fish database entry. See [[fish-database]] for the `color` field spec. Terminals without 256-color support fall back silently to the plain ASCII value.

## Caught-State Expiry

The statusline script computes `catch_age = now - caughtAt`. If `catch_age >= 120` seconds, the statusline renders the idle glyph (`~~*~~`) without waiting for Claude to write a reset. This makes the statusline self-contained for all state transitions except the initial catch event. Claude never writes an idle reset; the expiry is driven entirely by elapsed time.

## State File

The statusline reads `state.json` on every tick. Relevant fields:

| Field | Description |
|---|---|
| `fishermanName` | Displayed in the statusline |
| `state` | `"idle"` or `"caught"` |
| `caughtAt` | ISO 8601 UTC timestamp; used to compute catch_age |
| `catch.common` | Fish common name (caught state only) |
| `catch.ascii` | Fish ASCII art (caught state only) |
| `catch.color` | ANSI 256-color code (caught state only) |

For the full `state.json` schema, see [[persistence-layer]].

## Active-Session Detection

The statusline reads `session.json` to determine whether to show `~~*~~` or `~~~~~`. A session is considered active if `activatedAt` is within the last 8 hours. This avoids the need for Claude to write an `active` flag on every turn — the single timestamp in `session.json` is sufficient.

## Related

- [[persistence-layer]] — state.json and session.json schemas
- [[fish-database]] — color field and ASCII art guidelines
- [[leveling-system]] — rod tier ANSI color codes applied to `*` and `Lv.NN`
- [[shell-catch-hook]] — writes state.json on a catch
