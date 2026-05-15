---
name: refresh-deps-gradle
description: Internal worker that audits or updates a single Gradle project. Invoked by the refresh-deps orchestrator only.
user-invocable: false
disable-model-invocation: false
argument-hint: '<audit|update> --path <dir> --manifest <file> [--major] [--ignore <pkg,...>] [--skip-cache]'
---

# refresh-deps-gradle — Gradle project worker

You audit or update **exactly one** Gradle project. You are not user-facing.

## Hard constraints

- Never narrate reasoning. Emit only the JSON object produced by the script, verbatim.
- Audit is read-only.
- Never pass `--major` unless the caller explicitly included it.
- Never commit, push, or branch.
- Never silence non-zero exit codes.
- No discovery, no target resolution, no report formatting.

## Audit

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/audit-project.ps1 `
  --path "<path>" --type gradle --manifest "<manifest>" [--skip-cache] [--ignore <pkg,...>]
```

Echo the returned JSON verbatim.

## Update

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/update-project.ps1 `
  --path "<path>" --type gradle --manifest "<manifest>" [--major] [--ignore <pkg,...>]
```

Re-audit with `--skip-cache`; respond `[updateResult, auditResult]`.

## Tooling notes

- Outdated: `dependencyUpdates` task — requires the `com.github.ben-manes.versions` plugin. The script detects plugin presence and reports accordingly.
- CVEs: not natively supported without an additional plugin. Absence of CVE data is **not** a clean bill of health.
