# Spec 06 — Persistence Layer

**Status:** `DONE`

---

## Purpose

Defines how catch data is stored and read across sessions. All data lives in the user's home directory so it persists across different projects.

## Files

```
~/.claude/commands/refs/gone-fishing/refs/
├── catches.json    # cumulative catch log
├── profile.json    # selected fisherman character
└── state.json      # current fisherman state for the statusline
```

The `refs/` directory is created on first run if it does not exist.

## Schema

`catches.json` is a single JSON file containing a top-level array of catch records:

```json
{
  "version": 1,
  "catches": [
    {
      "fishId": "rainbow-trout",
      "common": "Rainbow Trout",
      "rarity": "common",
      "exp": 55,
      "timestamp": "2026-05-14T10:23:00.000Z"
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `version` | number | Schema version — increment on breaking changes |
| `catches[].fishId` | string | Matches `id` field in fish database |
| `catches[].common` | string | Denormalized common name (survives fish database edits) |
| `catches[].rarity` | string | Denormalized rarity tier snapshotted at catch time — used for stats breakdowns without rejoining `fish.json` |
| `catches[].exp` | number | EXP value snapshotted from `fish.json` at catch time — survives rebalancing |
| `catches[].timestamp` | string | ISO 8601 UTC timestamp of the catch |

Level and total EXP are **never stored directly** — they are always derived at runtime by summing `catches[].exp`. See [Spec 08](./08-leveling-system.md) for derivation logic.

## Read / Write Rules

- **Write:** Append a new catch record to `catches.catches` array and write the file atomically (write to `.tmp`, then rename).
- **Read:** Parse the JSON file; return empty array if file does not exist.
- **Schema mismatch:** If `version` field is missing or > current version, log a warning and treat as empty — do not overwrite existing data.
- **Corruption:** If the file is not valid JSON, log a warning and treat as empty — do not overwrite.

## Atomic Write Strategy

To prevent corruption from mid-write failures:
1. Serialize the updated data to a temp file: `catches.json.tmp`
2. Rename `catches.json.tmp` → `catches.json`

This ensures the file is never in a partially-written state.

## profile.json Schema

Stores the user's currently selected fisherman (see [Spec 07](./07-fisherman-roster.md)):

```json
{
  "version": 1,
  "fishermanId": "grizzled-pete",
  "assignedAt": "2026-05-14T10:00:00.000Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `version` | number | Schema version |
| `fishermanId` | string | Matches `id` in `fishermen.json` |
| `assignedAt` | string | ISO 8601 UTC timestamp of when this character was assigned |

Same atomic write rules (tmp → rename) and corruption handling apply.

## state.json Schema

Stores the fisherman's current state so the statusline script can read it without invoking Claude:

```json
{
  "version": 1,
  "fishermanName": "Grizzled Pete",
  "state": "idle",
  "catch": null
}
```

When a fish is caught, `state` becomes `"caught"` and `catch` is populated:

```json
{
  "version": 1,
  "fishermanName": "Grizzled Pete",
  "state": "caught",
  "catch": { "fishId": "rainbow-trout", "common": "Rainbow Trout", "ascii": "><(((º>", "exp": 30 }
}
```

Same atomic write rules (tmp → rename) apply. The statusline script reads this file on every refresh tick — it must never be left in a partially-written state.

## No Cloud Sync

Data is intentionally local-only. No syncing, no remote storage, no telemetry.

## Acceptance Criteria

- [ ] `refs/` directory is created on first run if it does not exist.
- [ ] `catches.json` is created on first catch if it does not exist.
- [ ] `profile.json` is created on first `/gone-fishing` run and persists across re-rolls.
- [ ] Each catch appends a new record with the correct `fishId`, `common`, `rarity`, `exp`, and UTC timestamp.
- [ ] Reads return an empty result gracefully when the file is missing.
- [ ] Writes are atomic (tmp → rename pattern).
- [ ] A corrupted or version-mismatched file does not crash the skill.
