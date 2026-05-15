---
name: doc-gen
description: Generate cross-linked API reference documentation for one or more workspace folders from platform-native intermediate formats (.NET XML docs, javadoc XML via xml-doclet, Dokka, TypeDoc JSON). Aggregates every buildable project under a workspace folder into `<workspace>/docs/` using pluggable **styles** (under `resources/styles/<style>/`) and **formats** (`{md,html,mdx}`). Default style `msdn`, default format `md`. Cross-references (`<see cref>`, `@link`, …) resolve forwards AND backwards across projects, and regeneration is differential — only projects whose git history changed since the last run are rebuilt. USE FOR building/refreshing the full reference site, validating MSDN-style markdown from XML doc comments, exporting MDX for a docs host, or regenerating a single project after a refactor.
user-invocable: true
argument-hint: "[<workspace-folder>...] [--style <name>] [--format md|html|mdx] [--output <path>] [--language dotnet|java|kotlin|typescript|javascript] [--project <name>]... [--force] [--force <project>]... [--xml-pattern <relative-path>]"
---

# doc-gen — orchestrator

Generate a cross-linked API reference site for one or more workspace folders.

## Output layout

```
<workspace>/docs/
+- README.<format>                  — workspace index (one table row per project)
+- .doc-gen-state.json              — per-project commit-SHA + xml hash
+- <Project>/
|   +- README.<format>              — project index (Classes/Structs/Interfaces/Enums/Delegates)
|   +- <Namespace>/
|       +- <Type>.<format>          — type page
|       +- <Type>/
|           +- <Member>.<format>    — one file per constructor/field/prop/method/event/operator
```

## Hard constraints

- Do not modify source code. The repo must already be wired to emit per-project XML docs (for .NET: the conditional PropertyGroup in `Directory.Build.props` that sets `GenerateDocumentationFile=true` and `DocumentationFile=$(MSBuildProjectDirectory)/bin/docs/docs.xml` for non-test projects).
- Never commit or push. `ship-it` handles that.
- Never silence a non-zero exit code from any script or subagent; surface it.
- Never invent content that is not present in the source intermediate docs.

## Step 1 — Prerequisite check

```
pwsh -NoProfile -File .github/skills/doc-gen/scripts/check-prereqs.ps1
```

`ok: true` → proceed. Otherwise stop and surface the missing prereq (PowerShell 7+ is required).

## Step 2 — Resolve arguments

Read [preferences.yaml](preferences.yaml) for defaults (`defaultStyle`, `defaultFormat`, `defaultOutputDir`, `autoExtract`, `autoDiscoverXml`, `stateFileName`, `onProjectFailure`). User flags override preferences.

| Flag                       | Purpose                                                        | Default             |
| -------------------------- | -------------------------------------------------------------- | ------------------- |
| `--style <name>`           | Style folder under `resources/styles/`                         | `msdn`              |
| `--format <md\|html\|mdx>` | Format folder under the style                                  | `md`                |
| `--output <path>`          | Output root (relative to target workspace)                     | `docs/`             |
| `--language <id>`          | Force a language, skip detection                               | auto                |
| `--project <name>`         | Restrict run to one or more project names (repeatable).        | all                 |
| `--xml-pattern <rel-path>` | Override per-project XML location.                             | `bin/docs/docs.xml` |
| `--force`                  | Regenerate every project regardless of state.                  | off                 |
| `--force <project>`        | Force-regenerate a specific project (repeatable, can combine). | —                   |

Validate that `resources/styles/<style>/<format>/` exists; otherwise stop and enumerate available styles/formats.

## Step 3 — Resolve target workspace folders

Rules (in order):

1. Explicit targets on the command line → resolve them to absolute paths; skip unresolved entries and surface them.
2. No target AND exactly one workspace folder is open → use it.
3. No target AND multiple workspace folders are open → prompt the user to pick one or more via `vscode_askQuestions` (multi-select). Each option is a workspace folder root.

## Step 4 — Discover projects

For each target workspace, call:

```
pwsh -NoProfile -File .github/skills/doc-gen/scripts/discover-projects.ps1 "<workspace>" -XmlPattern "<xml-pattern>"
```

The script returns one record per buildable non-test project, plus the resolved `xmlPath` when the per-project XML file is already on disk:

```jsonc
{ "path": "<abs>", "type": "dotnet", "manifest": "Foo.csproj", "project": "Foo", "xmlPath": "<abs>/bin/docs/docs.xml" | null }
```

If all projects return `xmlPath: null`, you have two choices:

- `autoExtract: true` (default) → dispatch the language extraction subagent(s) to build and emit per-project XML, then rediscover.
- `autoExtract: false` → stop and tell the user to run `dotnet build` (or equivalent) first.

Apply `--project <name>` filters after discovery.

## Step 5 — Dispatch language extractors (only when needed)

For each project whose `xmlPath` is still `null` after discovery, map type → subagent and dispatch:

| `type`       | Subagent             |
| ------------ | -------------------- |
| `dotnet`     | `doc-gen-dotnet`     |
| `java`       | `doc-gen-java`       |
| `kotlin`     | `doc-gen-kotlin`     |
| `typescript` | `doc-gen-typescript` |
| `javascript` | `doc-gen-javascript` |

For `.NET`, the subagent will run `dotnet build` with `GenerateDocumentationFile=true`. After extraction, re-run discover-projects.ps1 to pick up the freshly created `bin/docs/docs.xml` files.

## Step 6 — Aggregate + render

Delegate the full aggregate + render + state pipeline to `aggregate-workspace.ps1`:

```
pwsh -NoProfile -File .github/skills/doc-gen/scripts/aggregate-workspace.ps1 `
  -Workspace "<workspace>" `
  -OutputDir "<workspace>/docs" `
  -Style "<style>" -Format "<format>" `
  -XmlPattern "<xml-pattern>" `
  [-ProjectsOnly @('Foo','Bar')] `
  [-ForceProjects @('Foo')] `
  [-Force]
```

The script:

1. Compares each project's current git HEAD short-SHA and XML hash against `<output>/.doc-gen-state.json` and skips unchanged projects (unless `-Force`/`-ForceProjects`).
2. Runs `normalize-dotnet.ps1` for each changed project to produce a canonical JSON model in `<output>/.doc-gen-models/<Project>.json`.
3. Calls `render.ps1 -ModelPaths @(...)` with **every** project model (changed and unchanged alike so cross-project links are re-resolved).
4. Rewrites `{{xref:<id>|<label>}}` markers to relative markdown links across the whole output tree.
5. Writes `<output>/README.<format>` (workspace index).
6. Persists the updated state file.

The script prints a JSON summary:

```jsonc
{
  "output": "<abs>",
  "projects": [
    {
      "name": "Foo",
      "status": "generated|skipped|forced|failed",
      "reason": "...",
    },
  ],
  "totals": { "generated": 3, "skipped": 12, "forced": 1, "failed": 0 },
}
```

## Step 7 — Report

Emit a single summary table:

| Project           | Status    | Reason                                        |
| ----------------- | --------- | --------------------------------------------- |
| Elements.Core     | generated | commit c0ffee1                                |
| Elements.Data     | skipped   | no changes since last run                     |
| Elements.Logging  | forced    | commit d3adb33f                               |
| Elements.Security | failed    | assembly not found — run `dotnet build` first |

And print totals (`Generated | Skipped | Forced | Failed`) plus the output path. Close by pointing the user at `ship-it` if they want to commit the regenerated docs.

## Extensibility

- **New style**: create `resources/styles/<new>/` containing at least one `<format>/` folder with the required templates (see [resources/styles/README.md](resources/styles/README.md)).
- **New format under an existing style**: create `resources/styles/<style>/<format>/` with the same template set.
- **New language**: add a `doc-gen-<lang>.agent.md`, append to the `agents:` list above, extend the `type` map in [discover-projects.ps1](scripts/discover-projects.ps1), and add a token-dictionary entry for the new language key.
