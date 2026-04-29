# Coding Guidelines

Reference documents for language-specific coding standards. These are **deep-dive** companions to the distilled instruction files in `../../instructions/coding/`.

## How This Works

- **Auto-injected rules**: `../../instructions/coding/*.instructions.md` — loaded automatically by Copilot (via `applyTo`) and manually by other agents. Contains distilled, actionable rules.
- **Deep-dive references** (this directory): Loaded on demand when comprehensive detail is needed (style debates, design rationale, review checklists, quality attributes).

## Languages

### .NET (Active)

| File | Purpose |
|------|---------|
| Instructions: `../../instructions/coding/dotnet.instructions.md` | Auto-injected rules for `*.cs`, `*.csproj`, `*.sln` |
| Reference: `dotnet/style-guide.md` | Detailed formatting, naming, type declarations, member ordering |
| Reference: `dotnet/design-principles.md` | CQRS pipeline, Result/Error API, DDD patterns, specifications, events |
| Reference: `dotnet/code-review.md` | Systematic checklist for PR reviews |
| Reference: `dotnet/quality-attributes.md` | Performance, security, observability, resilience patterns |

### Java (Stub)

Instructions: `../../instructions/coding/java.instructions.md` — placeholder for future Java projects.

### Kotlin (Stub)

Instructions: `../../instructions/coding/kotlin.instructions.md` — placeholder for future Kotlin projects.

### Node.js / TypeScript (Stub)

Instructions: `../../instructions/coding/nodejs.instructions.md` — placeholder for future Node.js projects.
