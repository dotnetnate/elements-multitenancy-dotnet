# refresh-deps — report format

Authoritative rendering rules for the orchestrator's final report. Use this layout exactly. Do not improvise.

See [definitions.md](definitions.md) for badge ladders and status terms.

## Per-project sections

One `####` section per project, in workspace-folder order.

### Header (always emit)

```
#### `{workspace-relative-path}` · `{manifest}` · {type-label} · _{durationMs}ms_
```

- `.NET`: `{type-label}` = `.NET ({projectCount} projects)`.
- Use shortest unambiguous workspace-relative path.

### Status table (always emit)

| CVE Status | Package Status |
|---|---|
| {cve-badge} | {pkg-badge} |

### Vulnerability table — only when `critical > 0 OR high > 0`

Rows: critical first, then high. Omit moderate/low.

| Package | Version | Sev | Advisory | Title | CVSS | Fix |
|---|---|---|---|---|---|---|
| `name` | x.y.z | 🔴 CRITICAL | [GHSA-…](url) | title ≤65 chars | 9.8 | ✅ |

### Outdated table — only when `packages.outdated.length > 0`

| Package | Current | Wanted | Latest | Upgrade |
|---|---|---|---|---|
| `name` | 1.0.0 | 1.0.1 | 2.0.0 | 🔧 in-range |

For `.NET`, prepend a `Project` column (`.csproj` basename) before `Package`.

### Cache hit

If the subagent reports `cached: true`, replace all sub-tables with:

> _Served from cache — no manifest changes since {message}. ({durationMs}ms)_

## Workspace summary table

Render once after all per-project sections.

| # | Project | Type | CVE Status | Package Status | Time |
|---|---|---|---|---|---|
| 1 | `elements-dotnet/src` | .NET (82) | ✅ Clean | ✅ Up to date | 1,234ms |
| 2 | `entitlements` | .NET (61) | ⛔ Failed | ⛔ Failed | 312ms |
| 3 | `entitlements/…/admin-portal` | npm | 🔴 c=1 h=26 m=11 | 🟡 12 | 8,421ms |

Use abbreviated CVE badges (see [definitions.md](definitions.md)).

## Prioritised action list

Emit only non-empty categories, in this order:

1. 🔴 **Fix critical CVEs** — `package` ([advisory](url)) · projects affected
2. 🔴 **Fix high CVEs** — `package` ([advisory](url)) · projects affected
3. ⛔ **Resolve failed audits** — `{project}`: {reason}
4. 🔧 **Apply in-range updates** — {project list}
5. ⬆️ **Major upgrades available** — {project list}
6. 🟡 **Moderate/low CVEs** — {project list}

Close the report by directing the user to `ship-it` to commit any resulting changes.
