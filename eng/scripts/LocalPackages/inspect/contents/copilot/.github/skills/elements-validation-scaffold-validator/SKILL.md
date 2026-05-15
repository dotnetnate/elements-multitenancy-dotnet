---
name: elements-validation-scaffold-validator
description: Scaffolds a validator for a target DTO. For DataAnnotations, decorates the DTO with `[Required]`, `[StringLength]`, `[Range]`, etc. For FluentValidation, generates a `sealed class FooValidator : AbstractValidator<Foo>` placed next to the DTO with starter rules per property (NotEmpty / EmailAddress / range checks based on type and name patterns). USE FOR any "scaffold validator", "add validator", "generate validation rules" request.
argument-hint: "<DtoType>"
user-invocable: true
---

# elements-validation-scaffold-validator

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `dto-type` | DTO type name or file path? | _free text_ |
| `provider` | Validation provider to scaffold for? | `auto-detect` ★, `fluentvalidation`, `dataannotations` |

Skip `dto-type` when supplied as an argument. For `provider = auto-detect`: pick `fluentvalidation` when `Elements.Validation.Extensions.FluentValidation` is referenced, otherwise `dataannotations` when `Elements.Validation.Extensions.DataAnnotations` is referenced, otherwise stop and report.

## Procedure

1. **Resolve DTO.** Find the `<DtoType>` declaration and enumerate its public read-write properties (type + name). If multiple matches exist for the supplied name, stop and report.

2. **Add the package** for the chosen provider in the DTO's project, if not already referenced. Run, in the target project's directory:

   ```bash
   dotnet add package Elements.Validation.Extensions.FluentValidation
   ```

   or

   ```bash
   dotnet add package Elements.Validation.Extensions.DataAnnotations
   ```

   If the workspace has `Directory.Packages.props`, append `--no-restore` and surface a TODO to add the matching `<PackageVersion Include="..." Version="..."/>` entry.

3. **Generate validator** based on `provider`:

   **`fluentvalidation`** — create `<DtoFolder>/<DtoType>Validator.cs`:

   ```csharp
   using FluentValidation;

   namespace <Ns>;

   public sealed class <DtoType>Validator : AbstractValidator<<DtoType>>
   {
       public <DtoType>Validator()
       {
           <per-property rules>
       }
   }
   ```

   **`dataannotations`** — modify `<DtoType>` in place, adding attributes to each property. Add `using System.ComponentModel.DataAnnotations;` if missing.

4. **Per-property rule generation.** Apply this exhaustive substitution table in order; first match wins:

   | Property type / name pattern | FluentValidation rule | DataAnnotations attribute |
   |---|---|---|
   | `string` AND name contains `Email` (case-insensitive) | `RuleFor(x => x.<P>).NotEmpty().EmailAddress();` | `[Required] [EmailAddress]` |
   | `string` AND name contains `Url` or `Uri` | `RuleFor(x => x.<P>).NotEmpty().Must(u => Uri.TryCreate(u, UriKind.Absolute, out _)).WithMessage("<P> must be an absolute URI.");` | `[Required] [Url]` |
   | `string` AND name contains `Phone` | `RuleFor(x => x.<P>).NotEmpty().Matches(@"^\+?[0-9\-\s]{7,20}$");` | `[Required] [Phone]` |
   | `string` (other) | `RuleFor(x => x.<P>).NotEmpty().MaximumLength(256);` | `[Required] [StringLength(256)]` |
   | `Guid` | `RuleFor(x => x.<P>).NotEmpty();` | `[Required]` |
   | Numeric (`int`, `long`, `decimal`, `double`, `float`) | `RuleFor(x => x.<P>).GreaterThanOrEqualTo(0);` + `// TODO: confirm range` | `[Range(0, <type>.MaxValue)]` + `// TODO: confirm range` |
   | `DateTimeOffset` / `DateTime` | `RuleFor(x => x.<P>).NotEqual(default(<Type>));` | `[Required]` |
   | Collection (`IEnumerable<T>`, `IReadOnlyList<T>`, …) | `RuleFor(x => x.<P>).NotEmpty().Must(c => c.Count <= 100);` + `// TODO: confirm max count` | _not supported — emit `// TODO`_ |
   | Nullable variants | Same rule wrapped in `When(x => x.<P> is not null, () => { ... })` | Omit `[Required]`, keep other attributes |
   | Complex reference type | `RuleFor(x => x.<P>).SetValidator(new <Type>Validator()); // TODO: ensure <Type>Validator exists` | _not supported — emit `// TODO`_ |

5. **Build.** Run `dotnet build` on the target project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Validator: `<DtoType>Validator` (`<provider>`)
- Properties covered: `<count>`
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Generated rules are STARTING POINTS — every `// TODO` marker stays until the user reviews.
- Validators are pure: never inject application services or perform IO from the validator constructor.
- Never silently drop a property — emit `// TODO: define rule for <P>` when no rule applies.
- Validator class names follow `<DtoType>Validator` (singular, `Validator` suffix). A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elv0001](../../../docs/analyzer-roadmap.md#elv0001).