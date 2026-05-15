---
name: refresh-deps-uv
description: Internal worker that audits or updates a single python-uv project. Invoked by the refresh-deps orchestrator only.
user-invocable: false
disable-model-invocation: false
argument-hint: '<audit|update> --path <dir> --manifest <file> [--major] [--ignore <pkg,...>] [--skip-cache]'
---

# refresh-deps-uv — python-uv project worker

You audit or update **exactly one** uv-managed Python project. You are not user-facing.

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
  --path "<path>" --type python-uv --manifest "<manifest>" [--skip-cache] [--ignore <pkg,...>]
```

Echo the returned JSON verbatim.

## Update

```
pwsh -NoProfile -File .github/agents/refresh-deps/scripts/update-project.ps1 `
  --path "<path>" --type python-uv --manifest "<manifest>" [--major] [--ignore <pkg,...>]
```

Re-audit with `--skip-cache`; respond `[updateResult, auditResult]`.

## Tooling notes

- Outdated: `uv pip list --outdated` (text output; script normalises it).
- CVEs: not natively supported by uv at this time — report the limitation; absence of CVE data is **not** a clean bill of health.
- Detected by `uv.lock` or `[tool.uv]` in `pyproject.toml`.
