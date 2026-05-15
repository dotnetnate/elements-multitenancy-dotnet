# Elements skill style guide

Every Copilot skill emitted by [eng/scripts/generate-copilot-customizations.ps1](../scripts/generate-copilot-customizations.ps1) MUST conform to this guide. New skills that don't conform will be rejected at review.

This is the contract. It is not aspirational.

---

## 1. Terminology

| Use | Don't use |
|---|---|
| **skill** | "agent" (an agent is a top-level persona; skills are loaded *into* an agent) |
| **another skill** / **delegate to the `<name>` skill** | "subagent" |
| **chat model** / **the model** | "AI", "Copilot agent" |
| **invoke the `<tool_name>` tool** | "use the X tool", "ask the X tool" |

> A skill never refers to itself as an agent and never refers to other skills as agents or subagents. Agents are configured in `.github/agents/*.agent.md`; skills are dispatched *by* an agent.

## 2. Frontmatter

Every `SKILL.md` starts with YAML frontmatter:

```yaml
---
name: <kebab-case-skill-id>           # MUST equal the folder name
description: <one paragraph, ≤ 500 chars, third-person, ends with USE FOR triggers>
argument-hint: "[optional usage hint shown in /command picker]"
user-invocable: false                 # OPTIONAL — set when the skill is only dispatched by another skill
context: fork                         # OPTIONAL — when the skill should run in a forked context (long migrations)
---
```

`description` MUST:

- name the package(s) the skill works on
- describe the **deterministic** outputs (files created/edited)
- end with `USE FOR any "<phrase>", "<phrase>", "<phrase>" request.` listing the user-utterance triggers

## 3. Interview sections — actually invoke the tool

Skills that need information from the user MUST direct the model to **invoke the `vscode_askQuestions` tool**. The phrasing is fixed:

```markdown
## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (recommended ★) |
|---|---|---|
| `entity-name` | What is the entity name? | _free text_ |
| `id-type` | What is the id type? | `Guid` ★, `int`, `long`, `string` |
| `versioned` | Enable optimistic concurrency? | `yes` ★, `no` |

Skip any question whose answer is supplied via the skill argument or unambiguously detectable from the workspace (state how it is detected). Never ask a question whose answer can be reliably inferred.
```

**Forbidden phrasings** in skill bodies:

- "ask the user"
- "use the ask-questions tool"
- "the askQuestions tool"
- "ask in a single batch"

**Required phrasing**: "Invoke the `vscode_askQuestions` tool".

The headers in the table become the `header` field of each question; the labels in `options` map to `options[].label`. Mark the recommended default with `★` — the writer of the SKILL.md is responsible for translating that to `recommended: true` when calling the tool.

## 4. Package installation — run the dotnet CLI, don't paste XML

A skill that adds a NuGet dependency MUST direct the model to run the actual command. A bare `<PackageReference>` snippet is not enough — the model often pastes XML into a wrong file.

**Required form**:

```markdown
### 1. Add the package

Run, in the target project's directory:

```bash
dotnet add package Elements.IO.Extensions.AzureBlobStorage
dotnet add package Azure.Identity
```

Do NOT hand-edit the `.csproj`. If `dotnet add package` reports a downgrade or version conflict, surface the error verbatim — do not retry with `--version` unless the user explicitly supplies one.
```

If the consumer uses `Directory.Packages.props` (central package management), the skill MUST first detect that file and instead run:

```bash
dotnet add package <Name> --no-restore   # version is governed centrally
```

then surface a TODO to add the matching `<PackageVersion Include="..." Version="..."/>` entry to `Directory.Packages.props` if missing.

## 5. Generated C# code conventions

Code that a skill writes into the workspace MUST match the project's own `.github/instructions/dotnet.instructions.md` rules:

- `CancellationToken cancellationToken` — never `ct`, `token`, `cts`
- `sealed record` for DTOs / events / commands / queries
- `sealed class` for handlers / repositories / validators / services
- Constructor injection — never service-locator
- `async`/`await` end-to-end — never `.Result` / `.Wait()`
- Structured logging with named placeholders — never `$"..."` interpolation in templates
- `ArgumentNullException.ThrowIfNull` / `ArgumentException.ThrowIfNullOrWhiteSpace` for guard clauses

When emitting templates, use these conventions verbatim. Do not invent local shortcuts.

## 6. Determinism

Skills are deterministic procedures, not creative agents.

- Substitution tables MUST be exhaustive — list every supported transformation. Do not use language like "and similar" or "etc."
- Every step MUST have a clear precondition, action, and postcondition.
- When a question's answer cannot be determined, **ask** (via `vscode_askQuestions`) — do not guess.
- When a step's input is ambiguous, **stop and report** — do not fabricate.

## 7. Reporting

Every skill ends with a **Report** section the model emits as the final message:

```markdown
## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path), [file](path))
- Files modified: `<count>` ([file](path))
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number
```

## 8. Constraints sections — what NOT to do

A `## Constraints` section at the end lists the invariants the model must honor. Each constraint is one sentence; no rationale paragraphs. Bad constraints look like prose advice; good constraints look like rules.

Bad:

> Try to avoid putting credentials in appsettings.json because that can leak.

Good:

> Never write `ConnectionString`, `Password`, `AccessKey`, or `SecretKey` values into `appsettings.json` or `appsettings.<env>.json`. Use `dotnet user-secrets` or environment variables.

## 9. Companion templates

Long code blocks belong in `templates/<name>.md` next to `SKILL.md`, referenced via relative markdown links. Keep `SKILL.md` focused on PROCEDURE; keep templates focused on EXACT TEXT.

```markdown
Apply the patch in [templates/inject-clock.md](./templates/inject-clock.md).
```

## 10. Reporting violations → analyzer plan

Skills are runtime / on-demand tools. They cannot prevent a developer from typing `DateTime.UtcNow` tomorrow. Recurring rules that should be **always-enforced** belong in Roslyn analyzers — see [docs/analyzer-roadmap.md](../docs/analyzer-roadmap.md).

When a skill detects a class of violation that would benefit from being analyzer-enforced, it MUST include in its `## Constraints` section:

> A Roslyn analyzer for this rule is planned — see `docs/analyzer-roadmap.md#<anchor>`.

…and the rule MUST be present in the analyzer roadmap with that anchor. The skill remains useful for batch migration; the analyzer prevents regression.
