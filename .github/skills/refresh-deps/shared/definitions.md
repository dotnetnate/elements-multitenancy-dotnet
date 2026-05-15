# refresh-deps — shared definitions

These definitions are shared by the orchestrator and all PM subagents. Do not redefine them locally.

## Status terms

| Term | Condition |
|---|---|
| **Clean** | `packages.vulns.critical == 0 AND packages.vulns.high == 0` |
| **Up to date** | `packages.outdated.length == 0` |

Clean and Up to date are **independent** — a project can be either, both, or neither.

## CVE badge ladder (first match wins)

- `⛔ Failed — {reason}` — tool could not run
- `🔴 critical={N} high={N} moderate={N} low={N}` — `critical > 0` OR `high > 0`
- `🟡 moderate={N} low={N}` — only moderate/low
- `✅ Clean`

Abbreviated form for the workspace summary table:
- `🔴 c={N} h={N} m={N}` / `🟡 m={N}` / `✅` / `⛔`

## Package badge ladder (first match wins)

- `⛔ Could not determine` — tooling error or unsupported type
- `🟡 {N} package(s) outdated` — `packages.outdated.length > 0`
- `✅ Up to date`

## Severity icons

- `🔴 CRITICAL` — `packages.vulns.critical > 0` rows
- `🔴 HIGH` — `packages.vulns.high > 0` rows
- Moderate / Low — never rendered as table rows; only counted in badges.

## Fix availability icons (vulnerability table)

- `✅` — fix available within current major
- `❌` — no fix published
- `⬆️ major` — fix requires a semver-major bump

## Upgrade icons (outdated table)

- `🔧 in-range` — `current ≠ wanted`
- `⬆️ major` — `current == wanted` AND `latest` is a semver-major jump
- `🔧 + ⬆️ major` — both apply
