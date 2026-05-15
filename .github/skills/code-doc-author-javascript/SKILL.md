---
name: code-doc-author-javascript
description: Author or refresh JSDoc comments (`/** ... */` with `@param {Type}`, `@returns {Type}`, `@throws`, `@template`, `@example`, `@see`, `@deprecated`, …) on every type and member of a JavaScript project (no scope-based filtering — JS has no language-level visibility modifiers). Edits only JSDoc comment regions in `.js` / `.mjs` / `.cjs` files. Subagent dispatched by `code-doc-author` / `tech-writer`.
user-invocable: false
---

# doc-author-javascript

You author **JSDoc** comments on exported (and class-level) members.

> Embedded reference: Use JSDoc — *Block Tags Reference*.
> Source URLs (refresh on demand):
> - <https://jsdoc.app/>
> - <https://jsdoc.app/about-block-tags.html>
> - <https://jsdoc.app/about-inline-tags.html>

## Constraints

- DO edit only JSDoc blocks (`/** ... */`) immediately preceding the
  declaration they document.
- DO NOT modify code, imports, or `package.json`.
- DO include `{Type}` annotations on `@param` / `@returns` / `@type` —
  unlike TSDoc, JSDoc uses these to recover type information.
- DO use `@inheritdoc` (lowercase) on overrides / class implementations of
  documented members.
- JavaScript has no language-level access modifiers and the `_`-prefix
  convention is not universal, so **document every member** in the supplied
  files: module-level declarations (whether or not they appear in
  `module.exports` / `export`), class fields, instance methods, static
  methods, prototype assignments, and IIFE-exported members. The `--scope`
  flag is ignored here — the JS agent always operates as if `--scope all`.
- When the orchestrator passes a member classified as `contradicted`
  (only possible with `--verify-content`), correct only the specific
  clause cited in the finding — do not rewrite the rest of the prose.

## Definition of Done — per member (HARD RULE)

A member is fully documented ONLY when its JSDoc block contains EVERY
tag required for its kind. A `@description` (or summary) alone is NOT
sufficient. If any required element is missing the member is
`incomplete` — add what is missing, do not skip.

| Member kind | Required JSDoc |
|---|---|
| Type / class / namespace | summary; `@template` for each generic; **class-level `@example` block** (≤ 50 lines, hard cap 150) |
| Function / method | summary; `@param {Type} name - description` per parameter; `@template` per type parameter; `@returns {Type} description` if it returns a value; `@throws {Type} description` for each thrown error; **method-level `@example`** unless trivial |
| Property / field | summary; `@type {Type}`; `@throws` if accessor throws |
| Module-exported constant | summary; `@type {Type}` |
| Override / class implementation | `@inheritdoc` plus additive `@example` for non-trivial overrides |

*Trivial* (no `@example` required) is limited to one-line
accessors/setters that return or assign a backing field directly with
no validation, no thrown errors, and no domain semantics. Async
functions, validation helpers, factories, and event-emitter wrappers
are NON-TRIVIAL.

When `--examples off` is set, examples are suppressed; otherwise treat
them as mandatory. Do not count `incomplete` members as `skipped` in
your report.

## Embedded reference — block tags

| Tag | Purpose |
|---|---|
| `@param {Type} name - description` | One per parameter. |
| `@param {Type} [name=default] - description` | Optional parameter with default. |
| `@param {Type} name.subProp - description` | Object property of a parameter. |
| `@returns {Type} description` (`@return` synonym) | Return value. |
| `@throws {Type} description` (`@exception` synonym) | Explicit exception. |
| `@template T` | Generic type parameter (one per parameter). |
| `@type {Type}` | Type annotation for a variable / property. |
| `@typedef {Type} Name` | Define a reusable type. |
| `@callback Name` | Define a callback function type. |
| `@class` / `@constructor` | Mark a function as a constructor. |
| `@extends Type` (`@augments`) | Indicate inheritance. |
| `@implements {InterfaceType}` | Indicate interface implementation. |
| `@override` | Marks an override of a parent member. |
| `@inheritdoc` | Inherit doc from the parent symbol. |
| `@example <caption?>\n  <code>` | Code example. |
| `@see Reference` | Cross-reference. |
| `@since version` | Version introduced. |
| `@deprecated description` | Mark as deprecated. |
| `@public` / `@private` / `@protected` / `@package` | Access markers. |
| `@readonly` / `@constant` / `@default <value>` | Modifier tags. |

## Inline tags

| Tag | Purpose |
|---|---|
| `{@link <ref>\|<text>}` | Cross-reference link. |
| `{@linkcode <ref>}` / `{@linkplain <ref>}` | Variants. |
| `{@tutorial <id>}` | Reference a tutorial. |

## Type expressions

JSDoc uses Closure-style type expressions:
- `string`, `number`, `boolean`, `Object`, `Array`, `Function`
- `Array<string>` or `string[]`
- `Object<string, number>`
- `string | number` (union)
- `?string` (nullable), `!string` (non-nullable), `string=` (optional)
- `function(string, number): boolean` (function signature)
- `*` (any), `?` (unknown)

## Doc comment structure

```js
/**
 * Maps the source value to the destination type.
 *
 * @template TSource - The type to map from.
 * @template TDestination - The type to map to.
 * @param {TSource} input - The value to map; never null.
 * @returns {TDestination} The mapped value.
 * @throws {RangeError} If `input` is empty.
 *
 * @example
 * const mapper = new Mapper();
 * const result = mapper.map(input);
 *
 * @public
 */
```

## Approach

1. Walk every declaration in the supplied files: module-level
   functions/classes/consts, every class member (instance + static, regardless
   of `_`-prefix), prototype assignments, and any function attached to
   `module.exports` / `exports` / `export`.
2. For each `missing` member, insert a JSDoc block:
   - Summary derived from name + body, or `TODO: clarify intent of <member>.`
   - `@template` for every generic type parameter the codebase models (often
     declared in surrounding `@typedef`s).
   - `@param {Type} name - desc` for every parameter (use the most specific
     type expression you can derive from usage; fall back to `*` only when
     truly unknown and emit a TODO).
   - `@returns {Type}` for every function that does not return `undefined`.
   - `@throws {ExceptionType}` for every explicit `throw new ...`.
   - `@example` for non-trivial functions and class-level usage.
3. For class methods overriding a parent, use `@override` plus
   `@inheritdoc`.
4. For `stale` blocks, reconcile only affected tags. Do not change `@type`
   expressions on members whose runtime type was not actually changed.
5. Respect `--dry-run`.

## Output

```json
{ "file": "<abs>", "documented": 8, "skipped": 5, "stale": 1, "todos": [...] }
```
