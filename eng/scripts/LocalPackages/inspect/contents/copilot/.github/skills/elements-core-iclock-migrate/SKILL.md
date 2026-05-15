---
name: elements-core-iclock-migrate
description: Migrates ambient wall-clock reads (DateTime.UtcNow, DateTime.Now, DateTimeOffset.UtcNow, DateTimeOffset.Now) in a .NET project to the injected MyOrg.Elements.Time.IClock from Elements.Core. Injects an IClock field and constructor parameter on each enclosing type, rewrites every call site via a fixed substitution table, registers SystemClock in the composition root, and updates affected tests to use a controllable clock. USE FOR any "use IClock", "remove DateTime.UtcNow", "make time injectable", "migrate to IClock" request.
argument-hint: "[<path or glob>]"
user-invocable: true
context: fork
---

# elements-core-iclock-migrate

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `scope` | Which files should be migrated? | `entire workspace` ★, `single project`, _free text path or glob_ |
| `composition-root` | Which composition root should receive `services.AddSingleton<IClock, SystemClock>()`? | `auto-detect` ★, _free text path_ |
| `frozen-time` | What UTC instant should tests freeze to? | `2025-01-01T00:00:00Z` ★, _free text ISO-8601_ |

Skip `scope` when the user supplied a path argument. Detect the composition root by scanning for `Program.cs` files that call `Host.CreateApplicationBuilder` or `WebApplication.CreateBuilder`; if exactly one is found, do not ask.

## Procedure

1. **Scan.** Find every match of the regex `\bDateTime(?:Offset)?\.(?:UtcNow|Now)\b` in the in-scope `*.cs` files, excluding `bin/`, `obj/`, `*.g.cs`, `*.Designer.cs`, and files whose containing type name ends in `FakeClock`, `FrozenClock`, `StubClock`, or `TestClock`. Build a list of `{ file, line, enclosingType, kind, member }` violations.

2. **Add the package** in every project that contains a violation, if not already referenced. Run, in the target project's directory:

   ```bash
   dotnet add package Elements.Core
   ```

   If the workspace has `Directory.Packages.props`, run `dotnet add package Elements.Core --no-restore` and surface a TODO to add the matching `<PackageVersion Include="Elements.Core" Version="..."/>` entry.

3. **Inject `IClock` per enclosing type.** Group violations by enclosing type. For each type:
   - If the type already declares `private readonly IClock _clock;`, skip injection.
   - Otherwise add the field and a constructor parameter named `clock`. Apply the patch in [templates/inject-clock.md](./templates/inject-clock.md). Guard with `ArgumentNullException.ThrowIfNull(clock);`.
   - If the violation is in a `static` method on a `static` class, stop and emit a TODO at the call site — converting to instance is out of scope.

4. **Rewrite call sites.** Apply this exhaustive substitution table; do not paraphrase:

   | Original | Replacement |
   |---|---|
   | `DateTime.UtcNow` | `_clock.UtcNow.UtcDateTime` |
   | `DateTime.Now` | `_clock.LocalNow.LocalDateTime` |
   | `DateTimeOffset.UtcNow` | `_clock.UtcNow` |
   | `DateTimeOffset.Now` | `_clock.LocalNow` |

5. **Register `SystemClock`** in the chosen composition root. If `services.AddSingleton<IClock` already exists, leave it. Otherwise insert `builder.Services.AddSingleton<IClock, SystemClock>();` immediately after the first `builder.Services.Add*` call, or before `var app = builder.Build();`. Add `using MyOrg.Elements.Time;` if missing.

6. **Update tests.** For each affected type, find its matching test class `<TypeName>Tests`. Construct the SUT with a frozen `IClock` set to the user-supplied instant using [templates/test-fixture.md](./templates/test-fixture.md). If the test class uses a DI fixture, register the frozen `IClock` there instead.

7. **Build.** Run `dotnet build` on each affected project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Call sites rewritten: `<count>`
- Types receiving `IClock` injection: `<count>`
- Composition roots updated: `<list>`
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Never introduce `static` clock holders or service-locator lookups. A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elc0001](../../../docs/analyzer-roadmap.md#elc0001).
- Never modify `*.g.cs`, `*.Designer.cs`, or otherwise generated files.
- Never touch types in `*.Tests.*` projects whose name ends in `FakeClock`, `FrozenClock`, `StubClock`, or `TestClock`.
- This skill is additive — it never deletes existing time-related abstractions.