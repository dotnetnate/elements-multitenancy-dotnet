---
name: elements-validation-fluentvalidation
description: Wires Elements.Validation.Extensions.FluentValidation as the `IValidationService` implementation in the composition root. Adds the package references, registers `FluentValidationValidationService`, and configures `services.AddValidatorsFromAssemblyContaining<T>()` for assembly scanning of `AbstractValidator<T>` classes. Invoked only by the elements-validation skill.
user-invocable: false
---

# elements-validation-fluentvalidation

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `target-project` | Project containing the composition root? | `auto-detect` ★, _free text path_ |
| `scan-assembly-anchor` | Anchor type for assembly scanning (`AddValidatorsFromAssemblyContaining<T>`)? | `Program` ★, _free text type name_ |

Skip `target-project` when the parent `elements-validation` skill already passed it, or when exactly one composition root is detected.

## Procedure

1. **Resolve composition root.** Locate the `Program.cs` containing `WebApplication.CreateBuilder` or `Host.CreateApplicationBuilder`. If absent, stop and report.

2. **Add the packages** if not already referenced. Run, in the target project's directory:

   ```bash
   dotnet add package Elements.Validation.Extensions.FluentValidation
   dotnet add package FluentValidation.DependencyInjectionExtensions
   ```

   If the workspace has `Directory.Packages.props`, append `--no-restore` to each command and surface a TODO listing the missing `<PackageVersion Include="..." Version="..."/>` entries.

3. **Register the service** in the composition root, immediately before `var app = builder.Build();`:

   ```csharp
   builder.Services.AddValidatorsFromAssemblyContaining<<scan-assembly-anchor>>(ServiceLifetime.Singleton);
   builder.Services.AddSingleton<IValidationService, FluentValidationValidationService>();
   ```

   Add `using FluentValidation;`, `using MyOrg.Elements.Validation;`, and `using MyOrg.Elements.Validation.Extensions.FluentValidation;` if missing.

4. **Defer validator scaffolding.** Do not auto-generate validators here — direct the user to the `elements-validation-scaffold-validator` skill for each DTO.

5. **Build.** Run `dotnet build` on the target project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Registration: `IValidationService` → `FluentValidationValidationService` (singleton)
- Assembly scan anchor: `<scan-assembly-anchor>`
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Exactly one `IValidationService` registration per composition root — never stack a second implementation.
- One `sealed class FooValidator : AbstractValidator<Foo>` per DTO, placed in the same folder as the DTO.
- Validators are singletons — never store per-request mutable state on a validator.
- Never throw `ValidationException` from application code; return a typed failure instead. A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elv0001](../../../docs/analyzer-roadmap.md#elv0001).