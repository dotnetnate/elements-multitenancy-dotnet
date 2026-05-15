---
name: refresh-deps
description: Audit or update package-manager dependencies across a multi-folder workspace. Detects project type (npm/pnpm/yarn, python-pip/poetry/uv, maven, gradle, dotnet) and dispatches per-project work to specialised subagents in parallel. **Audit is the default mode** — lists outdated packages and highlights known critical/high CVEs without modifying anything. **Update mode** applies upgrades.
user-invocable: true
argument-hint: '[audit|update] [<repo-or-folder>...] [--major] [--skip-cache] [--ignore <pkg,...>]'
---

# refresh-deps — orchestrator

Audit or update package-manager dependencies across a multi-folder workspace. You are the entry point. You **discover** projects and **dispatch** per-project work to PM-specific subagents in parallel; you do **not** run audit/update commands yourself.

Shared references:
- [shared/definitions.md](shared/definitions.md) — Clean / Up-to-date, badge ladders, severity icons.
- [shared/report-format.md](shared/report-format.md) — exact rendering rules.

## Hard constraints

- Never narrate reasoning. Output results only.
- Audit is read-only — no manifest, lockfile, or config may be modified.
- Never run `--major` upgrades without explicit user consent in the current turn.
- Never silence a non-zero exit code from any subagent or script; surface it.
- Never commit, push, or create branches. That is `ship-it`'s job.

## Step 1 — Prerequisite check

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/check-prereqs.ps1
```

`ok: true` → proceed. Any failure → stop and report: _"refresh-deps requires PowerShell 7+. Install from https://aka.ms/powershell"_

## Step 2 — Determine mode and strategy

Read `.github/agents/refresh-deps/preferences.yaml` for `defaultMode`, `updateStrategy`, `onProjectFailure`.

Resolve mode in priority order:

1. Explicit user words: `audit` / `check` / `review` / `scan` → **audit**. `update` / `upgrade` / `bump` / `refresh` / `apply` → **update**.
2. Otherwise `defaultMode` (fallback: `audit`).

Update strategy:
- `in-range` (default) — minor/patch only, within declared version ranges.
- `major` — only when user explicitly says "latest", "major", or "breaking".

**Update mode mutates manifests.** Never enter it without explicit user intent in the current turn.

## Step 3 — Resolve targets

- **No targets specified** → scan every workspace folder.
- **Targets specified** → resolve via the helper:

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/resolve-targets.ps1 `
  --workspace "<ws1>" --workspace "<ws2>" `
  <target> [<target> ...]
```

Skip any entry where `resolved` is empty; surface its `error`.

## Step 4 — Discover projects

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/discover-projects.ps1 "<folder1>" "<folder2>" ...
```

Returns `[{path, type, tool, manifest, projectCount?}, ...]`. Empty array → tell user no supported projects detected and stop.

## Step 5 — Cache and `.gitignore` check

The audit script manages `refresh-deps.cache` at `.github/agents/refresh-deps/scripts/refresh-deps.cache`. Verify this path is excluded in the repo's root `.gitignore`. If missing, add it and inform the user: _"Added `refresh-deps.cache` to `.gitignore` — it contains machine-local absolute paths."_

## Step 6 — Dispatch subagents in parallel

For each project from Step 4, invoke its matching subagent **in a single parallel batch** via the `agent` tool. Use this fixed mapping:

| `type` | Subagent |
|---|---|
| `npm` | `refresh-deps-npm` |
| `pnpm` | `refresh-deps-pnpm` |
| `yarn` | `refresh-deps-yarn` |
| `python-pip` | `refresh-deps-pip` |
| `python-poetry` | `refresh-deps-poetry` |
| `python-uv` | `refresh-deps-uv` |
| `dotnet` | `refresh-deps-dotnet` |
| `maven` | `refresh-deps-maven` |
| `gradle` | `refresh-deps-gradle` |

Pass to each subagent: `mode` (`audit`/`update`), `--path "<path>"`, `--manifest "<manifest>"`, plus any user flags (`--major`, `--ignore <pkg,...>`, `--skip-cache`). Wait for all to return.

Respect `onProjectFailure`: `stop` → abort on first non-zero exit; `continue` → record failure and proceed.

## Step 7 — Aggregate and render

Each subagent returns either a single audit object or `[updateResult, auditResult]`. Aggregate them and render the report exactly per [shared/report-format.md](shared/report-format.md):

1. One per-project section per result, in workspace-folder order.
2. Workspace summary table.
3. Prioritised action list (only non-empty categories).

Close by directing the user to `ship-it` to commit any resulting changes.
