# Agentize: Transform Reference Docs → Agent-Optimized Instructions

> Reusable prompt for transforming human-readable `reference/` content into compact, agent-optimized `instructions/` files. Reference files are the source of truth; instruction files are derived outputs.

## Context

This repository uses a two-tier documentation system for AI agents:

1. **`reference/`** — Human-readable, verbose, comprehensive guides. The source of truth. Written for humans reviewing and maintaining standards.
2. **`instructions/`** — Compact, agent-optimized files with `applyTo` YAML frontmatter. Auto-injected into editor context windows. Written to minimize tokens while preserving all actionable rules.

The instruction files are **derived outputs** — they should be regenerable from the reference files at any time.

## Your Task

Transform the specified reference file(s) into compact instruction file(s). Apply the compression rules below to produce files that are **40–60% smaller** than the reference content while preserving **every actionable rule**.

## Compression Rules

### Format

- One rule per line where possible
- Use terse markers: `RULE:`, `NEVER:`, `PREFER:`, `WHEN:`, `PATTERN:`, `EXAMPLE:`
- Use `→` for mappings (e.g., `VALIDATION_ERROR → 400 Bad Request`)
- Inline short code in backticks rather than fenced blocks
- Use fenced code blocks ONLY for multi-line patterns that cannot be expressed inline
- Remove all prose explanations — keep only the rule itself
- Remove "why" commentary — agents don't need motivation
- Remove section introductions and transitions
- Collapse tables into compact lists when rows ≤ 5

### Structure

```markdown
---
applyTo: "{glob pattern}"
---

# {Title}

{Rules in terse format}

## Deep-Dive

→ `reference/{path-to-source-file}.md`
```

Every instruction file MUST end with a `## Deep-Dive` section pointing to its reference source.

### What to Preserve

- Every MUST / MUST NOT / NEVER rule
- Naming patterns and conventions
- Code structure patterns (fixture layout, test class naming)
- Error mapping tables
- Tool/library requirements
- Correct/incorrect examples (use ✅/❌ markers, inline)

### What to Remove

- Introductory paragraphs and motivation ("This guide covers...")
- Detailed explanations of why a rule exists
- Redundant examples (keep ONE exemplar per pattern)
- Section transitions ("Now let's look at...")
- Long prose descriptions of tools (reader already knows them)
- Comments in code examples unless the comment IS the rule

## File Mapping

When agentizing, use this mapping from reference → instruction:

### Coding Instructions

| Reference Source | Instruction Output | applyTo |
|-----------------|-------------------|---------|
| `reference/coding/dotnet/style-guide.md` + `design-principles.md` | `instructions/coding/dotnet.instructions.md` | `"**/*.cs,**/*.csproj,**/*.sln"` |

### .NET Testing Instructions

| Reference Source | Instruction Output | applyTo |
|-----------------|-------------------|---------|
| `reference/testing/general.md` + `dotnet/unit-tests.md` | `instructions/testing/unit-tests.instructions.md` | `"**/*.Tests.Unit/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/integration-tests.md` | `instructions/testing/integration-tests.instructions.md` | `"**/*.Tests.Integration/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/build-verification-tests.md` | `instructions/testing/build-verification-tests.instructions.md` | `"**/*.Tests.Validation/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/http-api-tests.md` | `instructions/testing/http-api-tests.instructions.md` | `"**/*.Service.Http.Tests.*/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/grpc-api-tests.md` | `instructions/testing/grpc-api-tests.instructions.md` | `"**/*.Service.Grpc.Tests.*/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/graphql-api-tests.md` | `instructions/testing/graphql-api-tests.instructions.md` | `"**/*.Service.GraphQL.Tests.*/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/console-cli-tests.md` | `instructions/testing/console-cli-tests.instructions.md` | `"**/*.Service.Console.Tests.*/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/performance-tests.md` | `instructions/testing/performance-tests.instructions.md` | `"**/*performance*/**/*.cs,**/*perf*/**/*.cs,**/*benchmark*/**/*.cs,**/*load*/**/*.cs"` |
| `reference/testing/general.md` + `dotnet/contract-tests.md` | `instructions/testing/contract-tests.instructions.md` | `"**/*contract*/**/*.cs,**/*pact*/**/*.cs,**/*consumer*/**/*.cs,**/*provider*/**/*.cs"` |

### Web Frontend Testing Instructions

| Reference Source | Instruction Output | applyTo |
|-----------------|-------------------|---------|
| `reference/testing/web-frontend-tests.md` | `instructions/testing/web-frontend-tests.instructions.md` | `"**/*e2e*/**/*.ts,**/*playwright*/**/*.ts,**/*.spec.ts,**/*.e2e.ts"` |

## Compression Example

### Reference (verbose)

```markdown
## Test Method Naming

Pattern: `Given_{Context}_When_{Action}_Then_{Expected_Result}`. Always include an underscore 
between ALL words — never use PascalCase within a segment.

Here are examples of correct and incorrect naming:

- Correct: `Given_Valid_Command_When_Project_Exists_Then_Returns_Success`
- Correct: `Given_Empty_Name_When_Create_Called_Then_Throws_Argument_Exception`
- Incorrect: `Given_ValidCommand_When_ProjectExists_Then_ReturnsSuccess`
- Incorrect: `Given_Create_Called_When_ValidParameters_Then_WorkItemCreatedWithPendingStatus`

The underscore convention ensures test names are readable in test explorers and CI output.
```

### Instruction (compressed)

```markdown
PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Command_When_Project_Exists_Then_Returns_Success`
❌ `Given_ValidCommand_When_ProjectExists_Then_ReturnsSuccess`
```

## Quality Checks

After generating an instruction file, verify:

- [ ] Every MUST/NEVER rule from the reference is present
- [ ] `applyTo` frontmatter matches the mapping table above
- [ ] File ends with `## Deep-Dive` pointing to reference source(s)
- [ ] No prose introductions or explanations remain
- [ ] Code examples are minimal (one per pattern, not three)
- [ ] Test naming examples use underscores between ALL words
- [ ] No `localhost` defaults or hardcoded URLs appear anywhere
- [ ] File is 40–60% smaller than the combined reference sources

## Usage

To regenerate all instruction files from reference:

```
For each row in the File Mapping tables above:
1. Read the reference source file(s)
2. Apply the compression rules
3. Write the instruction output file with correct applyTo frontmatter
4. Run the quality checks
```

To regenerate a single instruction file:

```
1. Identify which reference file(s) feed into the instruction (see mapping table)
2. Read those reference files
3. Apply compression rules
4. Overwrite the instruction file
5. Run quality checks
```
