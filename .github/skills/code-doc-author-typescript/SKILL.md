---
name: code-doc-author-typescript
description: Author or refresh TSDoc comments (`/** ... */` with `@param`, `@returns`, `@remarks`, `@example`, `@throws`, `@typeParam`, `{@link}`, `{@inheritDoc}`, …) on exported types and members of a TypeScript project. Edits only TSDoc comment regions in `.ts` / `.tsx` files. Subagent dispatched by `code-doc-author` / `tech-writer`.
user-invocable: false
---

# doc-author-typescript

You author **TSDoc** comments on exported types and members.

> Embedded reference: Microsoft — *TSDoc specification*.
> Source URLs (refresh on demand):
> - <https://tsdoc.org/>
> - <https://tsdoc.org/pages/tags/alpha/>
> - <https://tsdoc.org/pages/spec/overview/>
>
> TSDoc is the canonical doc syntax for TypeScript; tools such as TypeDoc and
> API Extractor consume it.

## Constraints

- DO edit only TSDoc blocks (`/** ... */`) immediately preceding the
  declaration they document.
- DO NOT modify code, imports, `tsconfig.json`, or `package.json`.
- DO NOT use JSDoc-only `{type}` annotations (e.g. `@param {string} foo`).
  Types come from the TypeScript signatures; TSDoc descriptions are plain
  prose.
- DO use `{@inheritDoc <package>#<member>}` on overrides / interface
  implementations.
- ONLY document `export`-ed declarations by default (class members inherit
  visibility from `public` / `protected` modifiers — `private` is excluded).
  With `--scope all`, also document module-private and `private`
  declarations.
- When the orchestrator passes a member classified as `contradicted`
  (only possible with `--verify-content`), correct only the specific
  clause cited in the finding — do not rewrite the rest of the prose.

## Definition of Done — per member (HARD RULE)

A member is fully documented ONLY when its TSDoc block contains EVERY
tag required for its kind. A summary paragraph alone is NOT sufficient.
If any required element is missing the member is `incomplete` — add
what is missing, do not skip.

| Member kind | Required TSDoc |
|---|---|
| Type (class / interface / type alias / enum) | summary; `@typeParam` per generic parameter; **class-level fenced `@example`** (≤ 50 lines, hard cap 150) |
| Function / method | summary; `@param <name> - <desc>` per parameter; `@typeParam` per type parameter; `@returns` if it returns a value; `@throws` for each thrown / rejecting error type; **method-level `@example`** unless trivial |
| Property / accessor | summary or `@defaultValue`; `@throws` if accessor throws |
| Override / interface impl | `{@inheritDoc <ref>}`; additive `@example` for non-trivial overrides |

*Trivial* (no `@example` required) is limited to one-line
accessors/setters returning or assigning a backing field directly with
no validation, no thrown errors, no domain semantics. `Try*` patterns,
async functions, factories, and validation helpers are NON-TRIVIAL.

When `--examples off` is set, examples are suppressed; otherwise treat
them as mandatory. Do not count `incomplete` members as `skipped` in
your report.

## Embedded reference — standard tags

### Block tags

| Tag | Purpose |
|---|---|
| `@param <name> - <description>` | One per parameter; the hyphen is required. Type info comes from the signature. |
| `@typeParam <name> - <description>` | One per type parameter. |
| `@returns <description>` | Return value description. |
| `@remarks <description>` | Extended description (everything before the first block tag is the summary). |
| `@example <caption?>\n```ts\n…\n``` ` | Code example. Use a fenced TypeScript block. |
| `@throws <description>` | Explicitly thrown exceptions. |
| `@deprecated <description>` | Marks the API as deprecated. |
| `@see <reference>` | Cross-reference. |
| `@defaultValue <expr>` | Default value for a property. |
| `@public` / `@beta` / `@alpha` / `@internal` | Release-stage modifiers (recognised by API Extractor). |
| `@override`, `@sealed`, `@virtual` | Modifier tags. |
| `@privateRemarks` | Internal remarks excluded from rendered docs. |

### Inline tags

| Tag | Purpose |
|---|---|
| `{@link <ref> \| <text>}` | Cross-reference link. |
| `{@linkcode <ref>}` | Cross-reference rendered in monospace. |
| `{@linkplain <ref>}` | Cross-reference in plain font. |
| `{@inheritDoc <ref>}` | Inherit doc from the referenced symbol. |
| `{@label <id>}` | Declaration reference disambiguator. |

### Declaration references

`{@link MyClass}`, `{@link MyClass.method}`,
`{@link my-package#MyClass.method}`, `{@link (overload:1)}`. Brackets, not
parentheses, when piping a custom label: `{@link MyClass | the class}`.

## Doc comment structure

```ts
/**
 * Maps the source value to the destination type.
 *
 * @remarks
 * Discusses edge cases, complexity, threading, …
 *
 * @typeParam TSource - The type to map from.
 * @typeParam TDestination - The type to map to.
 * @param input - The value to map; never `null`.
 * @returns The mapped value.
 * @throws RangeError if `input` is empty.
 *
 * @example
 * ```ts
 * // class-level usage sample, ≤ 50 lines, hard cap 150
 * const mapper = new Mapper<Foo, Bar>();
 * const bar = mapper.map(foo);
 * ```
 *
 * @public
 */
```

- The **first paragraph** before any block tag is the summary.
- Hyphen between `@param <name>` and the description is mandatory.
- Use Markdown in descriptions; TSDoc preserves it for renderers.

## Approach

1. Walk every exported declaration (`export class`, `export interface`,
   `export type`, `export const|let|function`, default exports). Class members
   inherit visibility from `public`/`protected` modifiers (default `public`).
2. For each `missing` member, insert a TSDoc block:
   - Summary derived from name + body, or `TODO: clarify intent of <member>.`
   - `@typeParam` for every type parameter.
   - `@param` for every parameter, even obvious ones.
   - `@returns` for non-`void` / non-`Promise<void>` functions.
   - `@throws` for every `throw new ...` in the body.
   - `@example` block for non-trivial functions and class-level usage.
   - Add `@public` / `@internal` / `@beta` only when the project already
     uses these (look for `.api.md` / `api-extractor.json`).
3. For overrides / implementations, prefer
   `{@inheritDoc <package>#<member>}`.
4. For `stale` members, reconcile only affected tags.
5. Respect `--dry-run`.

## Output

```json
{ "file": "<abs>", "documented": 11, "skipped": 6, "stale": 1, "todos": [...] }
```
