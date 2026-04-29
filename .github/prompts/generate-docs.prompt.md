---
agent: agent
---

# Documentation Generation Prompt — Microsoft Learn API Reference Style

You are a documentation generation agent for the **Elements .NET framework**. Generate comprehensive markdown documentation for every packable (non-test) project under `/src`, following the **Microsoft Learn API Reference** style exactly.

---

## 1  Scope

### What to document

| Artifact | Location | File name |
| --- | --- | --- |
| Per-type page (class, record, struct, enum, interface) | `/docs/<category>/` | `<Project>.<TypeName>.md` |
| Per-member page (method, property, constructor, field) | `/docs/<category>/` | `<Project>.<TypeName>.<MemberName>.md` |
| Project-level overview | `/docs/<category>/` | `<Project>.md` |
| Category README | `/docs/<category>/` | `README.md` |
| Architecture documents (one per subsystem) | `/docs/architecture/` | `<subsystem>.md` |

**Note**: For overloaded members, use the signature in the filename: `<Project>.<TypeName>.<MemberName>-<ParamTypes>.md` where `<ParamTypes>` is a dash-separated list of parameter type names (e.g., `String.Substring-Int32-Int32.md`).

**`<category>`** is derived from the second segment of the project name, lowercased:
`Elements.Security.Identity.Abstractions` → `security`.

**`<Project>`** is the exact assembly/project name as defined in the `.csproj` file name (not the namespace). Must match exactly including suffixes like `Abstractions`, `Extensions`, etc.

### What to exclude

- Test projects (any project whose name contains `.Tests.`)
- `internal`, `private`, and `file`-scoped types
- Auto-generated types (e.g. source-generator output)

---

## 2  Per-Type Page Structure

Use the following structure for every public type. Member tables link to dedicated per-member pages (see §3). Omit any section heading that has no content (e.g. if a class has no fields, omit "Fields").

```
# <TypeName> <Kind>                          ← e.g. "Result Class", "IEventStore Interface"

Namespace: <full.namespace>
Assembly:  <AssemblyName>.dll

<1-2 sentence summary of the type's purpose.>

## Definition

<Longer description: what the type represents, when and why to use it,
relationship to other types in the framework.>

```csharp
public <kind> <TypeName>
```

### Type Parameters  (if generic)

| Name | Description |
| --- | --- |
| `T` | <description with constraints noted inline> |

### Inheritance  (if class/record)

Object → <base> → … → **TypeName**

### Implements  (if any interfaces)

- IDisposable
- IEquatable\<T\>

## Examples

<A concise, runnable C# example showing typical usage.
  Use `// <highlight>` comments sparingly to call attention to key lines.>

## Remarks

<Design rationale, thread-safety notes, performance guidance,
relationship to other framework components, migration notes.>

## Constructors

| Constructor | Description |
| --- | --- |
| [TypeName()](Project.TypeName.-ctor.md) | <summary from XML docs> |
| [TypeName(Type1)](Project.TypeName.-ctor-Type1.md) | <summary from XML docs> |

## Fields  (if any)

| Field | Type | Description |
| --- | --- | --- |
| [SomeField](Project.TypeName.SomeField.md) | string | <summary from XML docs> |

## Properties

| Property | Type | Description |
| --- | --- | --- |
| [Name](Project.TypeName.Name.md) | string | <summary from XML docs> |
| [IsValid](Project.TypeName.IsValid.md) | bool | <summary from XML docs> |

## Methods

| Method | Description |
| --- | --- |
| [DoWork()](Project.TypeName.DoWork.md) | <summary from XML docs> |
| [DoWork(Int32)](Project.TypeName.DoWork-Int32.md) | <summary from XML docs> |
| [ProcessAsync(String, CancellationToken)](Project.TypeName.ProcessAsync-String-CancellationToken.md) | <summary from XML docs> |

## Extension Methods  (if any discovered in the solution)

| Method | Defined in | Description |
| --- | --- | --- |
| [ToJson(this TypeName)](ExtensionsProject.TypeNameExtensions.ToJson-TypeName.md) | TypeNameExtensions | <summary from XML docs> |

## See Also

- [RelatedType](Project.RelatedType.md)
- [Conceptual Guide](../architecture/<subsystem>.md)
```

---

## 3  Per-Member Page Structure

Create a dedicated page for **each public member** (constructor, method, property, field, event) following Microsoft Learn conventions.

### Constructor Page

```
# <TypeName> Constructor

Namespace: <full.namespace>
Assembly:  <AssemblyName>.dll

<1-2 sentence summary of what this constructor does.>

## Overloads  (if multiple constructors exist)

| Constructor | Description |
| --- | --- |
| [TypeName()](Project.TypeName.-ctor.md) | <summary> |
| [TypeName(Type1)](Project.TypeName.-ctor-Type1.md) | <summary> |
| [TypeName(Type1, Type2)](Project.TypeName.-ctor-Type1-Type2.md) | <summary> |

## TypeName(Type1, Type2)  (the specific overload this page documents)

<Longer description of when and why to use this overload.>

```csharp
public TypeName(Type1 param1, Type2 param2)
```

### Parameters

- `param1`  [Type1](Project.Type1.md)
  
  <description from XML docs>

- `param2`  [Type2](Project.Type2.md)
  
  <description from XML docs>

### Exceptions

| Exception | Condition |
| --- | --- |
| [ArgumentNullException](System.ArgumentNullException.md) | `param1` is `null`. |
| [ArgumentException](System.ArgumentException.md) | `param2` is empty or whitespace. |

## Examples

```csharp
// Example of using this constructor
var instance = new TypeName("value", 42);
```

## Remarks

<Additional notes, performance considerations, thread-safety, etc.>

## See Also

- [TypeName Class](Project.TypeName.md)
- [Related Method](Project.TypeName.RelatedMethod.md)
```

### Method Page

```
# <TypeName>.<MethodName> Method

Namespace: <full.namespace>
Assembly:  <AssemblyName>.dll

<1-2 sentence summary of what this method does.>

## Overloads  (if multiple overloads exist)

| Method | Description |
| --- | --- |
| [MethodName()](Project.TypeName.MethodName.md) | <summary> |
| [MethodName(Int32)](Project.TypeName.MethodName-Int32.md) | <summary> |
| [MethodName(String, Int32)](Project.TypeName.MethodName-String-Int32.md) | <summary> |

## MethodName(String, Int32)  (the specific overload this page documents)

<Longer description of what this overload does, when to use it.>

```csharp
public Result<T> MethodName(string input, int count)
```

### Parameters

- `input`  [String](https://learn.microsoft.com/en-us/dotnet/api/system.string)
  
  <description from XML docs>

- `count`  [Int32](https://learn.microsoft.com/en-us/dotnet/api/system.int32)
  
  <description from XML docs>

### Returns

[Result&lt;T&gt;](Project.Result-T.md)

<description of return value and semantics from XML docs>

### Exceptions

| Exception | Condition |
| --- | --- |
| [ArgumentNullException](https://learn.microsoft.com/en-us/dotnet/api/system.argumentnullexception) | `input` is `null`. |
| [InvalidOperationException](https://learn.microsoft.com/en-us/dotnet/api/system.invalidoperationexception) | The instance is not initialized. |

## Examples

```csharp
var result = instance.MethodName("test", 5);
if (result.IsSuccess)
{
    Console.WriteLine(result.Value);
}
```

## Remarks

<Design notes, performance considerations, thread-safety, alternative approaches.>

## See Also

- [TypeName Class](Project.TypeName.md)
- [Result&lt;T&gt; Class](Project.Result-T.md)
```

### Property Page

```
# <TypeName>.<PropertyName> Property

Namespace: <full.namespace>
Assembly:  <AssemblyName>.dll

<1-2 sentence summary of what this property represents.>

```csharp
public string PropertyName { get; set; }
```

## Property Value

[String](https://learn.microsoft.com/en-us/dotnet/api/system.string)

<description from XML docs>

## Examples

```csharp
var instance = new TypeName();
instance.PropertyName = "value";
Console.WriteLine(instance.PropertyName);
```

## Remarks

<Notes about the property, default values, validation, thread-safety, etc.>

## See Also

- [TypeName Class](Project.TypeName.md)
- [Related Property](Project.TypeName.RelatedProperty.md)
```

### Field Page

```
# <TypeName>.<FieldName> Field

Namespace: <full.namespace>
Assembly:  <AssemblyName>.dll

<1-2 sentence summary of what this field represents.>

```csharp
public const string FieldName = "value";
```

## Field Value

[String](https://learn.microsoft.com/en-us/dotnet/api/system.string)

<description from XML docs>

## Remarks

<Notes about the field, its purpose, when it was introduced, etc.>

## See Also

- [TypeName Class](Project.TypeName.md)
```

---

## 4  Project-Level Overview (`<Project>.md`)

```
# <Project>

**Namespace:** `<default namespace>`
**Assembly:** `<AssemblyName>.dll`
**NuGet:** `dotnet add package <Project>`

## Overview

<2-4 paragraph summary sourced from the project description in
the .csproj or existing README.md. Include the problem it solves,
when to use it, and how it fits into the Elements framework.>

## Installation

```shell
dotnet add package <Project>
```

## Getting Started

<Minimal "hello world" example showing basic registration and usage.>

## Usage Examples

<2-3 focused examples covering the most common scenarios.>

## Configuration

<If the library has DI registration helpers, options classes, or
configuration sections, document them here with examples.>

## API Reference

| Type | Summary |
|---|---|
| [ClassName](Elements.Project.ClassName.md) | <summary> |
| [IInterfaceName](Elements.Project.IInterfaceName.md) | <summary> |
```

---

## 5  Category README (`/docs/<category>/README.md`)

```
# <Category> Libraries

<Brief paragraph describing the subsystem.>

## Packages

| Package | Description |
|---|---|
| [Elements.Category.Abstractions](Elements.Category.Abstractions.md) | <summary> |
| [Elements.Category.Extensions.X](Elements.Category.Extensions.X.md) | <summary> |

## Architecture

See [<Subsystem> Architecture](../architecture/<subsystem>.md) for design details.
```

---

## 6  Architecture Documents (`/docs/architecture/<subsystem>.md`)

Create one architecture document for each of these subsystems:

1. **core** — Core primitives, error hierarchy, Result pattern
2. **applicationmodel** — Pipeline, CQRS, domain-driven design, event sourcing
3. **data** — Data access abstractions and extensions
4. **security** — Identity, claims, authorization
5. **validation** — Validation abstractions and provider integrations
6. **messaging** — Messaging abstractions and extensions
7. **observability** — Logging, tracing, metrics, and observability

Each architecture document should include:
- System overview and design goals
- Component diagram (Mermaid `graph TD`)
- Key abstractions and their relationships
- Extension points
- Cross-cutting concerns (DI, configuration, error handling)

---

## 7  Update Rules

| Situation | Action |
| --- | --- |
| New public type added | Create its per-type page, per-member pages for all public members, and update the project-level page |
| Public type removed | Delete its per-type page, all per-member pages, and remove from project-level page |
| New public member added | Create its per-member page and update the per-type page member table |
| Public member removed | Delete its per-member page and remove from the per-type page member table |
| Member signature changed | Update its per-member page and the per-type page member table |
| Existing doc matches code | Leave unchanged — do not rewrite for style alone |
| In-project README.md exists under `/src` | Treat as _source material_ for the project-level overview — do not copy verbatim; rewrite in Microsoft Learn style |
| Cross-referencing another project | Verify the referenced project exists under `/src/<category>/`. Use exact project names from `.csproj` files including all suffixes (`.Abstractions`, `.Extensions.X`, etc.). Never invent project names—for example, there is no "ApplicationModel.Core"; use `Elements.ApplicationModel.Abstractions` instead. |

---

## 8  Style Rules

- **Voice:** Third-person, present tense ("Gets the value…", "Represents a…").
- **Code fences:** Always `csharp` for C# code.
- **Links:** Use relative markdown links between docs.
- **Tables:** Use GFM pipe tables with spaces in separator rows: `| --- | --- |` (not `|---|---|`). Align column content for readability.
- **Abbreviations:** Spell out on first use, then abbreviate (e.g., "Domain-Driven Design (DDD)").
- **Nullable annotations:** Reflect nullable reference type annotations in signatures.
- **XML doc priority:** If a member has `<summary>`, `<param>`, `<returns>`, or `<exception>` XML doc comments in source, use them as the primary source of truth for descriptions.
- **Inheritance direction:** Base classes must NOT reference derived classes in "See Also" or elsewhere. Derived classes MAY reference their base classes. This maintains proper abstraction boundaries (e.g., `Error` base class should not list `ValidationError`, `NotFoundError`, etc., but those derived types can reference `Error`).

---

## 9  Markdownlint Compliance

All generated or updated markdown files **must** pass markdownlint validation with default rules before completion.

**Critical rules:**

- **MD060 (table-column-style)**: Table separator rows must have spaces: `| --- | --- |` not `|---|---|`
- **MD024**: Avoid duplicate headings within the same document
- **MD009**: No trailing spaces
- **MD010**: No hard tabs
- **MD036**: No emphasis as heading

---

## 10  Execution

**Parallelize work using subagents** to maximize throughput. Follow this workflow:

### Phase 1: Discovery

1. Discover all packable projects under `/src` (exclude `*.Tests.*` projects).
2. Group projects by category (derived from second segment of project name).

### Phase 2: Parallel Documentation Generation

3. For **each category**, launch a subagent to handle all projects in that category in parallel. Each subagent should:
   - Scan all public types in the category's projects
   - For each public type, scan all public members (constructors, methods, properties, fields, events)
   - Generate or update per-type pages with member summary tables linking to per-member pages
   - Generate or update per-member pages for all public members
   - Generate or update project-level pages for the category's projects
   - Report completion status back to the main agent

4. While subagents are working on categories, generate or update category READMEs in parallel.

5. While subagents are working, generate or update architecture documents in parallel (one subagent per subsystem: core, applicationmodel, data, security, validation, messaging, observability).

### Phase 3: Cleanup and Validation

6. After all subagents complete, remove documentation files whose corresponding types or members no longer exist.
7. Validate all generated/updated files pass markdownlint by checking for violations in the #problems window.
8. Report summary of all changes (files created, updated, deleted).

**Important**: Do **not** stop or ask for input. Complete the full task autonomously. Use the `runSubagent` tool to launch parallel workers. Each subagent should be given clear instructions about which category or architecture document to generate, and should work independently without coordination.