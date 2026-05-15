---
name: refresh-deps-poetry
description: Internal worker that audits or updates a single python-poetry project. Invoked by the refresh-deps orchestrator only.
user-invocable: false
disable-model-invocation: false
argument-hint: '<audit|update> --path <dir> --manifest <file> [--major] [--ignore <pkg,...>] [--skip-cache]'
---

# refresh-deps-poetry — python-poetry project worker

You audit or update **exactly one** Poetry-managed Python project. You are not user-facing.

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
  --path "<path>" --type python-poetry --manifest "<manifest>" [--skip-cache] [--ignore <pkg,...>]
```

Echo the returned JSON verbatim.

## Update

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/update-project.ps1 `
  --path "<path>" --type python-poetry --manifest "<manifest>" [--major] [--ignore <pkg,...>]
```

Re-audit with `--skip-cache`; respond `[updateResult, auditResult]`.

## Tooling notes

- Outdated: `poetry show --outdated` (text output; script normalises it).
- CVEs: `pip-audit` against the resolved environment. Without `pip-audit`, the script emits the missing-tool marker — surface as-is.
- Detected by `pyproject.toml` containing `[tool.poetry]`.
