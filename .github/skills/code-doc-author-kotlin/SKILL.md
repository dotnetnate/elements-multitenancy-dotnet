---
name: code-doc-author-kotlin
description: Author or refresh KDoc comments (`/** ... */` with `@param`, `@return`, `@throws`, `@property`, `@constructor`, `@receiver`, `@sample`, `@see`, …) on public types and members of a Kotlin project. Edits only KDoc comment regions in `.kt` / `.kts` files. Subagent dispatched by `code-doc-author` / `tech-writer`.
user-invocable: false
---

# doc-author-kotlin

You author **KDoc comments** on public types and members.

> Embedded reference: JetBrains — *Documenting Kotlin code (KDoc)*.
> Source URL (refresh on demand): <https://kotlinlang.org/docs/kotlin-doc.html>

## Constraints

- DO edit only KDoc comment regions (`/** ... */`) immediately preceding the
  declaration they document.
- DO NOT modify code, imports, package declarations, or Gradle/Maven files.
- DO use `@suppress` only when the user explicitly requests excluding a
  member.
- DO use Markdown — KDoc bodies are Markdown, not HTML.
- ONLY document `public` and `protected` declarations by default. Kotlin's
  default visibility is `public`, so any declaration without an explicit
  modifier is in scope. With `--scope all`, also document `internal`.
- When the orchestrator passes a member classified as `contradicted`
  (only possible with `--verify-content`), correct only the specific
  clause cited in the finding — do not rewrite the rest of the prose.

## Definition of Done — per member (HARD RULE)

A member is fully documented ONLY when its KDoc block contains EVERY tag
required for its kind. A summary line alone is NOT sufficient. If any
required element is missing the member is `incomplete` — add what is
missing, do not skip.

| Member kind | Required |
|---|---|
| Type (class / interface / object / enum) | summary; `@param <T>` for each type parameter; `@property` for documented constructor properties; **class-level usage `@sample` or fenced ```kotlin``` example** (≤ 50 lines, hard cap 150) |
| Function | summary; `@param` per value parameter; `@param <T>` per type parameter; `@return` if non-`Unit`; `@throws` for each explicitly thrown / documented exception; **method-level fenced example** unless the function is a *trivial* one-line property/accessor / data-class auto-generated member |
| Property | summary; `@throws` if accessor throws; example only when accessor is non-trivial |
| Override / interface impl | `{@inheritDoc}` style or full re-doc; additive example for non-trivial overrides |

`Try*`-pattern functions, suspending functions, builders, factories,
and extension functions are all NON-TRIVIAL — examples are required.

When `--examples off` is set, examples are suppressed; otherwise treat
them as mandatory. Do not count `incomplete` members as `skipped` in
your report — adding the missing pieces is part of the job.

## Embedded reference — block tags

| Tag | Purpose |
|---|---|
| `@param <name> <description>` | One per parameter, in declaration order. |
| `@param <T> <description>` | Type parameter (use the type parameter's name). |
| `@return <description>` | Return value, required for non-`Unit` functions. |
| `@throws <Class> <description>` (`@exception` synonym) | Each explicitly thrown exception. |
| `@receiver <description>` | Description of an extension function/property's receiver. |
| `@constructor <description>` | Documents the primary constructor at the class level. |
| `@property <name> <description>` | Documents a property declared in the primary constructor (because that property has no separate declaration site). |
| `@sample <fully.qualified.function>` | Embeds the body of a sample function. |
| `@see <reference>` | Cross-reference. |
| `@author`, `@since`, `@deprecated` | As in Javadoc. |
| `@suppress` | Exclude from generated docs. |

## Inline references

- `[ClassName]`, `[member]`, `[ClassName.member]` — Markdown-link-style
  cross-references resolved by Dokka against the symbol table.
- Inline code uses backticks (` `code` `), not `{@code}`.

## Doc comment structure

```kotlin
/**
 * <First sentence summary ending in a period.>
 *
 * <Optional Markdown body. Use [SymbolName] for cross-references.>
 *
 * ```kotlin
 * // class-level usage example, ≤ 50 lines, hard cap 150
 * ```
 *
 * @param T the element type
 * @param input the value to map; must not be empty
 * @return the mapped result
 * @throws IllegalArgumentException if [input] is empty
 * @sample com.example.samples.mapperUsageSample
 */
```

- The **first paragraph** is the summary used in member tables.
- Order block tags: `@param` (declaration order), `@return`, `@throws`,
  `@receiver`, `@constructor`, `@property`, `@sample`, `@see`, `@since`,
  `@deprecated`, `@suppress`.
- For primary-constructor properties, document them with `@property` on the
  enclosing class doc rather than on the constructor signature.

## Approach

1. Walk every public/protected (= unmodified) declaration.
2. For each `missing` member, insert a KDoc block:
   - Markdown summary derived from name + body, or a `TODO` line if unclear.
   - `@param` for every parameter and every type parameter.
   - `@return` for non-`Unit` functions.
   - `@throws` for every explicit `throw <Exception>(...)` in the body.
   - For data classes: ensure `@property` for each constructor-declared
     property. For regular classes with `init`-set properties, document them
     on their declaration site instead.
   - Class-level fenced `` ```kotlin `` example, or `@sample` if the
     repository already has a sample.
3. For overrides — Kotlin auto-inherits KDoc; do not insert empty blocks.
   Add a doc block only when adding additive prose beyond the parent's.
4. For `stale` members, reconcile only the affected tags.
5. Respect `--dry-run`.

## Output

```json
{ "file": "<abs>", "documented": 7, "skipped": 3, "stale": 0, "todos": [...] }
```
