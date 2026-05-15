---
name: elements-validation-dataannotations
description: Wires Elements.Validation.Extensions.DataAnnotations as the `IValidationService` implementation in the composition root. Adds the package reference and registers `DataAnnotationsValidationService` as a singleton, plus a one-time guidance comment listing supported annotations and the `IValidatableObject` extension point. Invoked only by the elements-validation skill.
user-invocable: false
---

# elements-validation-dataannotations

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `target-project` | Project containing the composition root? | `auto-detect` ★, _free text path_ |

Skip `target-project` when the parent `elements-validation` skill already passed it, or when exactly one composition root is detected.

## Procedure

1. **Resolve composition root.** Locate the `Program.cs` containing `WebApplication.CreateBuilder` or `Host.CreateApplicationBuilder`. If absent, stop and report.

2. **Add the package** if not already referenced. Run, in the target project's directory:

   ```bash
   dotnet add package Elements.Validation.Extensions.DataAnnotations
   ```

   If the workspace has `Directory.Packages.props`, run `dotnet add package Elements.Validation.Extensions.DataAnnotations --no-restore` and surface a TODO to add the matching `<PackageVersion Include="Elements.Validation.Extensions.DataAnnotations" Version="..."/>` entry.

3. **Register the service** in the composition root, immediately before `var app = builder.Build();`:

   ```csharp
   builder.Services.AddSingleton<IValidationService, DataAnnotationsValidationService>();
   ```

   Add `using MyOrg.Elements.Validation;` and `using MyOrg.Elements.Validation.Extensions.DataAnnotations;` if missing.

4. **Insert guidance comment** once, immediately above the registration:

   ```csharp
   // Annotate DTOs with [Required], [StringLength], [Range], [RegularExpression], etc.
   // For cross-field rules, implement IValidatableObject on the DTO.
   // DataAnnotations does NOT support async rules or deep nested-object validation.
   ```

5. **Build.** Run `dotnet build` on the target project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Registration: `IValidationService` → `DataAnnotationsValidationService` (singleton)
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Exactly one `IValidationService` registration per composition root — never stack a second implementation.
- Never throw `ValidationException` from application code; return a typed failure instead. A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elv0001](../../../docs/analyzer-roadmap.md#elv0001).
- Never decorate DTOs with both DataAnnotations attributes and a FluentValidation `AbstractValidator<T>` for the same type.