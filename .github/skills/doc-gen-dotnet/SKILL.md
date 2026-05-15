---
name: doc-gen-dotnet
description: Extract .NET API documentation from a C# project into the doc-gen canonical JSON model. Locates or generates the compiler XML doc file (via `GenerateDocumentationFile`), combines it with reflection metadata from the built assembly to recover signatures/visibility/inheritance, and writes a single canonical JSON file. Invoked as a subagent by `doc-gen`.
user-invocable: false
---

# doc-gen-dotnet

Extract documentation for a single .NET project (`.csproj` / `.sln`) into the canonical JSON model consumed by the `doc-gen` renderer.

## Inputs

- `--path <project-root>` — folder containing the `.csproj` / `.sln`.
- `--manifest <file>` — the specific manifest to build (e.g. `MyLib.csproj`).
- `--output-model <file>` — destination path for the canonical JSON.

## Approach

1. Ensure a compiler XML doc file exists alongside the built assembly. If it is missing and `autoExtract` is enabled, run:
   ```
   pwsh -NoProfile -File .github/skills/doc-gen/scripts/extract-dotnet.ps1 `
     -ProjectPath "<path>" -Manifest "<manifest>"
   ```
   This builds the project with `-p:GenerateDocumentationFile=true` into a temporary output and returns the paths to the produced `*.dll` and `*.xml`.
2. Normalize the compiler XML + assembly metadata into the canonical model:
   ```
   pwsh -NoProfile -File .github/skills/doc-gen/scripts/normalize-dotnet.ps1 `
     -XmlPath "<doc.xml>" -AssemblyPath "<assembly.dll>" `
     -OutputModel "<canonical.json>"
   ```
3. Return the path to the written canonical JSON and a summary `{project, elements, types, members}`.

## Constraints

- Do not modify the project's `.csproj`. Pass `GenerateDocumentationFile` on the command line only.
- Never invent doc content — elements with no XML doc comments render as empty-state placeholders in the templates.
- Surface all non-zero exit codes from `dotnet` without retry.

## Output

On success, print a single JSON line to stdout:

```json
{
  "project": "MyLib",
  "modelPath": "<canonical.json>",
  "types": 42,
  "members": 187
}
```
