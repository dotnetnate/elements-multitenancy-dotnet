---
name: elements-validation
description: Selects and wires the Elements.Validation IValidationService provider in a .NET application. Detects existing registrations, removes conflicts, and delegates to the elements-validation-dataannotations or elements-validation-fluentvalidation skill to install the chosen package and register the implementation. USE FOR any "configure validation", "add validators", "wire IValidationService", "switch validation provider" request.
argument-hint: "[<provider>]"
user-invocable: true
---

# elements-validation

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `provider` | Which validation provider should `IValidationService` resolve to? | `fluentvalidation` ★, `dataannotations` |
| `target-project` | Project containing the composition root? | `auto-detect` ★, _free text path_ |
| `replace-existing` | An existing `IValidationService` registration was detected. Replace it? | `no` ★ (stop), `yes` |

Skip `provider` when supplied as an argument. Skip `target-project` when exactly one composition root is detected. Skip `replace-existing` when no existing registration is found.

## Procedure

1. **Resolve composition root.** Locate the `Program.cs` containing `WebApplication.CreateBuilder` or `Host.CreateApplicationBuilder`. If multiple are found, stop and report.

2. **Detect existing registration.** Search the target project for any `services.AddSingleton<IValidationService, ...>` or `services.AddScoped<IValidationService, ...>` call. If one exists and the user did not confirm replacement, stop and report.

3. **Remove the previous registration** if `replace-existing = yes`. Validators authored for the previous provider (`DataAnnotations` attributes vs `AbstractValidator<T>` classes) are NOT migrated — emit a TODO listing them.

4. **Delegate to the provider skill.**
   - `dataannotations` → delegate to the `elements-validation-dataannotations` skill.
   - `fluentvalidation` → delegate to the `elements-validation-fluentvalidation` skill.

5. **Build.** Run `dotnet build` on the target project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Provider: `<dataannotations|fluentvalidation>`
- Replaced previous provider: `<yes|no>`
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Exactly one `IValidationService` provider per composition root.
- Never auto-migrate validators between providers — surface a TODO list instead.
- Never throw `ValidationException` from application code; the gate returns a typed failure. A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elv0001](../../../docs/analyzer-roadmap.md#elv0001).