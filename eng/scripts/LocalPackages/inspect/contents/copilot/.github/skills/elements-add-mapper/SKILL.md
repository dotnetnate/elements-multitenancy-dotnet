---
name: elements-add-mapper
description: Scaffolds an ITypeMapper<TSource, TDestination> implementation from Elements.Core for a source→destination type pair. When the target project already references Riok.Mapperly the mapper is generated as a Mapperly partial class; otherwise it is written by hand. Supports two-way (bidirectional) mapping on a single class. Places the file in the project's Mappers/ folder (or a user-supplied path) and wires it into the composition root via AddTypeMappersFromAssembly / AddTypeMapping. USE FOR any "add mapper", "create mapper", "map between types", "add type mapping", "object projection", "two-way mapper" request.
argument-hint: "<TSource> [<TDestination>]"
user-invocable: true
---

# elements-add-mapper

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header             | question                                                     | options (★ = recommended)               |
| ------------------ | ------------------------------------------------------------ | --------------------------------------- |
| `source-type`      | Source type name or file path?                               | _free text_                             |
| `destination-type` | Destination type name or file path?                          | _free text_                             |
| `two-way`          | Generate a two-way (bidirectional) mapper on the same class? | `no` ★, `yes`                           |
| `target-project`   | Which project should own the mapper class?                   | `auto-detect` ★, _free text path_       |
| `output-folder`    | Output folder within the project?                            | `Mappers/` ★, _free text relative path_ |

Skip `source-type` / `destination-type` when supplied as the skill argument.  
Skip `target-project` when exactly one non-test project in the workspace references `Elements.Core`.  
Skip `output-folder` if the project already contains a `Mappers/` directory — use it automatically.  
If either type name resolves to multiple workspace declarations, stop and report the ambiguity.

## Procedure

### 1. Resolve types

Find the `TSource` and `TDestination` class or record declarations in the workspace. Capture:

- Fully-qualified type name (namespace + class name).
- All public, readable properties. For each property record: name, CLR type, nullability, and whether it has a public setter or `init` accessor.

If `two-way` is `yes`, treat `TDestination` as a second source and collect its properties too.

### 2. Detect the Mapperly mode

Inspect the target project's `.csproj` for a `<PackageReference Include="Riok.Mapperly" .../>` entry (any version). Set `mode = mapperly` if found, otherwise `mode = handwritten`.

### 3. Add the `Elements.Core` package if not already referenced

Run, in the target project's directory:

```bash
dotnet add package Elements.Core
```

If the workspace uses `Directory.Packages.props`, run `dotnet add package Elements.Core --no-restore` instead, then surface a TODO to add a `<PackageVersion Include="Elements.Core" Version="..."/>` entry to `Directory.Packages.props`.

### 4. Generate the mapper file

**Output path**: `<TargetProject>/<output-folder>/<TSource>To<TDestination>Mapper.cs`

---

#### mode = mapperly

```csharp
using MyOrg.Elements.Mapping;
using Riok.Mapperly.Abstractions;

namespace <Ns>;

/// <summary>
/// Maps <see cref="<TSource>"/> to <see cref="<TDestination>"/> (and reverse, if two-way)
/// using Mapperly source generation.
/// </summary>
[Mapper]
public sealed partial class <TSource>To<TDestination>Mapper
    : ITypeMapper<<TSource>, <TDestination>>
{
    /// <inheritdoc/>
    public partial <TDestination> Map(<TSource> source);

    /// <inheritdoc/>
    public partial void Project(<TSource> source, [MappingTarget] <TDestination> destination);
}
```

For the `Project` method Mapperly requires the existing-target parameter to be decorated with `[MappingTarget]` so the source generator emits in-place property assignments rather than constructing a new instance. See [Mapperly existing-target docs](https://mapperly.riok.app/docs/configuration/existing-target/).

If `two-way` is `yes`, add the reverse interface and partials to the **same** class:

```csharp
[Mapper]
public sealed partial class <TSource>To<TDestination>Mapper
    : ITypeMapper<<TSource>, <TDestination>>
    , ITypeMapper<<TDestination>, <TSource>>
{
    /// <inheritdoc/>
    public partial <TDestination> Map(<TSource> source);

    /// <inheritdoc/>
    public partial void Project(<TSource> source, [MappingTarget] <TDestination> destination);

    /// <inheritdoc/>
    public partial <TSource> Map(<TDestination> source);

    /// <inheritdoc/>
    public partial void Project(<TDestination> source, [MappingTarget] <TSource> destination);
}
```

After writing the file, review each destination property against its source counterpart and annotate the class with the appropriate attribute:

| Situation                                                 | Action                                                                                                            |
| --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Same name, assignment-compatible type                     | No annotation needed — Mapperly handles it automatically.                                                         |
| Destination property has no corresponding source property | Add `[MapperIgnoreTarget(nameof(<TDest>.<Prop>))]` to the class and emit `// TODO: no source for <TDest>.<Prop>`. |
| Names differ, types compatible                            | Add `[MapProperty(nameof(<TSrc>.<SrcProp>), nameof(<TDest>.<DestProp>))]`.                                        |
| Same name, incompatible types                             | Add `// TODO: incompatible types for <Prop> — add a [MapProperty] and a user-defined conversion method`.          |

---

#### mode = handwritten

```csharp
using MyOrg.Elements.Mapping;

namespace <Ns>;

/// <summary>
/// Maps <see cref="<TSource>"/> to <see cref="<TDestination>"/> by hand.
/// </summary>
public sealed class <TSource>To<TDestination>Mapper
    : ITypeMapper<<TSource>, <TDestination>>
{
    /// <inheritdoc/>
    public <TDestination> Map(<TSource> source)
    {
        ArgumentNullException.ThrowIfNull(source);
        return new <TDestination>
        {
            <for each matched property: DestProp = source.SrcProp,>
            // TODO: <DestProp> — no matching source property found
        };
    }

    /// <inheritdoc/>
    public void Project(<TSource> source, <TDestination> destination)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(destination);
        <for each matched property: destination.DestProp = source.SrcProp;>
        // TODO: destination.<DestProp> — no matching source property found
    }
}
```

Property matching rules for handwritten mode (apply in order; first match wins):

| Priority | Condition                                                       | Action                                                                              |
| -------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| 1        | Same name (case-insensitive) and assignment-compatible CLR type | Emit `destination.Dest = source.Src;` (exact casing from the declaration).          |
| 2        | Same name, type requires explicit cast                          | Emit `destination.Dest = (<DestType>)source.Src;` and add a `// TODO: verify cast`. |
| 3        | No source counterpart                                           | Emit `// TODO: destination.<DestProp> — no source property found`.                  |

If `two-way` is `yes`, also implement `ITypeMapper<<TDestination>, <TSource>>` on the same class using the same rules applied in reverse (swap source and destination roles).

---

### 5. Wire the mapper into the composition root

Locate the composition root (`Program.cs` or equivalent that calls `AddObservability` / `AddTypeMapping` / `Host.CreateApplicationBuilder` / `WebApplication.CreateBuilder`).

Add the assembly scan registration if not already present:

```csharp
builder.Services
    .AddTypeMappersFromAssembly(typeof(<TSource>To<TDestination>Mapper).Assembly)
    .AddTypeMapping();
```

If `AddTypeMapping()` is already called, add only the `AddTypeMappersFromAssembly(...)` line (it is idempotent for the same assembly).  
Add `using MyOrg.Elements.Mapping;` to the file if missing.

### 6. Build

Run `dotnet build` on the target project and capture the last 20 lines of output. Compile errors at `// TODO` markers are expected and intentional — surface them in the report so the user addresses them explicitly.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Mapper mode: `mapperly` | `handwritten`
- Two-way: `yes` | `no`
- Properties mapped automatically: `<count>`
- Properties needing TODO review: `<count>`
- Packages installed: `<list>`
- Build status: `succeeded` | `failed` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Never invent property values — emit `// TODO` for every destination property that has no obvious source.
- Property name matching is case-insensitive for detection only; the emitted code uses the exact casing from the type declaration.
- In Mapperly mode the mapper class MUST be `sealed partial` and decorated with `[Mapper]`.
- In Mapperly mode the `Project` void method MUST annotate its second parameter with `[MappingTarget]`; without this attribute Mapperly generates a new-instance mapping instead of an in-place update.
- In handwritten mode the mapper class MUST be `sealed` (not partial) and MUST NOT carry `[Mapper]`.
- Never register individual `ITypeMapper<,>` instances directly in DI — always use `AddTypeMappersFromAssembly` so future mappers in the same assembly are picked up automatically.
- Never introduce static mapper registries, service-locator lookups, or factory delegates.
- Never modify generated files (`*.g.cs`, `*.Designer.cs`).
- If the target project uses `Directory.Packages.props`, always use `dotnet add package --no-restore` and surface the `<PackageVersion>` TODO.
- Do not add `Riok.Mapperly` to a project that does not already reference it — if the user wants Mapperly they should add it manually first, then re-run this skill.
