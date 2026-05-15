---
name: find-projects
description: Enumerate buildable projects across one or more workspace roots and return a path-to-project-type table. Discovers .NET (.csproj/.fsproj/.vbproj/.sln), Node.js (package.json), Python (pyproject.toml/requirements.txt), Java (pom.xml, build.gradle), Kotlin (build.gradle.kts), Go (go.mod), Rust (Cargo.toml), Ruby (Gemfile), PHP (composer.json) projects. Accepts explicit file or directory paths, auto-detects VS Code (`*.code-workspace`, `${workspaceFolders}`) and IntelliJ / JetBrains (`.idea/`, `modules.xml`, `*.iml`) workspaces, or falls back to the current working directory. Returns a markdown table by default; supports JSON and CSV output for downstream skills. USE FOR any "find/list/enumerate/discover projects" request, when an orchestrator skill (tech-writer, doc-gen, refresh-deps) needs to know which projects exist before fanning out work, or whenever a user asks "what projects are in this workspace".
user-invocable: true
argument-hint: '[<path>...] [--workspace] [--languages dotnet,nodejs,python,java,kotlin,go,rust,ruby,php] [--max-depth <n>] [--include-ignored] [--format table|json|csv]'
---

# find-projects — workspace project enumerator

You enumerate buildable projects across one or more roots and return a
table mapping each project file path to its project type. You are the
shared discovery primitive used by `tech-writer`, `doc-gen`,
`refresh-deps`, and any future skill that needs to know what's in the
workspace before fanning work out.

## Determine roots (priority order — first match wins, except explicit args always take precedence)

1. **Explicit path arg(s)** — one or more positional paths, or
   `--paths a;b;c`. Each path may be:
   - A **directory** — used as a scan root.
   - A **single project file** (`*.csproj`, `package.json`, `pom.xml`,
     `pyproject.toml`, …) — resolves to its parent directory before
     scanning.
   - A **workspace descriptor** — expanded per the rules below.
2. **`--workspace` flag** (default when no path args are supplied) —
   detect the host IDE and use its workspace concept:
   - **VS Code**: prefer `${workspaceFolders}` if injected by the host.
     Otherwise look for a `*.code-workspace` file in the current
     directory or any ancestor and parse `folders[].path` (resolve
     relative paths against the workspace file's directory).
   - **IntelliJ / JetBrains** (incl. Rider, PyCharm, WebStorm): detect by
     a `.idea/` folder at or above the current directory.
     - Multi-module: parse `.idea/modules.xml` for
       `<module fileurl="file://$PROJECT_DIR$/...">` entries; each
       module's containing directory becomes a root (one root per
       module).
     - Fallback: any `*.iml` file's directory.
     - Final fallback: the `.idea/` parent directory.
3. **Current working directory** — fallback when neither of the above
   resolves any roots.

All resolved roots are normalised to absolute paths and de-duplicated
before scanning.

## Scan

Invoke the bundled script:

```pwsh
pwsh [scripts/find-projects.ps1](scripts/find-projects.ps1) `
  -Roots <resolved-roots> `
  [-Languages <csv>] `
  [-MaxDepth 8] `
  [-IncludeIgnored] `
  [-Format table|json|csv]
```

The script performs filesystem enumeration with the standard ignore list
(`node_modules`, `bin`, `obj`, `.venv`, `target`, `dist`, `build`,
`.git`, `.idea`, `.vs`, `out`).

## Detection table

| Pattern | Project Type label |
|---|---|
| `*.csproj`, `*.fsproj`, `*.vbproj` | `.NET` |
| `*.sln` | `.NET (Solution)` |
| `package.json` | `Node.js` |
| `pyproject.toml` | `Python` |
| `requirements.txt` (no `pyproject.toml` sibling) | `Python (legacy)` |
| `pom.xml` | `Java (Maven)` |
| `build.gradle`, `build.gradle.kts`, `settings.gradle*` | `Java/Kotlin (Gradle)` |
| `Cargo.toml` | `Rust` |
| `go.mod` | `Go` |
| `Gemfile` | `Ruby` |
| `composer.json` | `PHP` |

## Output contract

Default `--format table` — emit a markdown table sorted by path:

```markdown
| Path | Project Type |
|---|---|
| /repos/app/src/App/App.csproj | .NET |
| /repos/app/web/package.json | Node.js |
```

When more than one root is supplied, prepend a `Repo` column whose value
is the relative root that contains the match (cheap multi-root
disambiguator):

```markdown
| Repo | Path | Project Type |
|---|---|---|
| entitlements | l:/repos/entitlements/Entitlements.sln | .NET (Solution) |
| swarm | l:/repos/swarm/package.json | Node.js |
```

Other formats:
- `--format json` — `[ { "path": ..., "type": ..., "language": ..., "repo": ... } ]`.
- `--format csv` — `path,type,language[,repo]`.

If no projects are found, emit a one-line "No projects found under
`<roots>`." note. Always exit successfully — empty results are not
errors.

## Caller integration notes

- Orchestrator skills should pass `--languages <csv>` to scope discovery
  (e.g. `code-doc-author-dotnet` consumer passes `--languages dotnet`).
- The `--format json` output is the recommended interchange for skill-
  to-skill consumption — caller parses, re-groups by project type, and
  fans out platform workers.
- For multi-root workspaces (the common case in this repository),
  always pass `--workspace` (default) or every relevant root — never
  rely on CWD alone.
