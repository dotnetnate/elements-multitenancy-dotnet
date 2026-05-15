# Styles

A **style** is a container for one or more **format** template sets. A style may define style-level preferences in `style.yaml` (optional).

```
resources/styles/
  <style-name>/
    style.yaml           # optional style-wide options
    md/                  # markdown format
      <templates>
    html/                # html format (optional)
      <templates>
    mdx/                 # mdx format (optional)
      <templates>
```

## Required templates per format

Every format directory **must** contain the following templates. The renderer uses `kind` from the canonical model to select one.

| File | Used for `kind` |
|---|---|
| `class.md` (or `.html` / `.mdx`) | `class`, `interface`, `struct`, `record` |
| `method.md` | `method`, `extension-method` |
| `constructor.md` | `constructor` |
| `property.md` | `property` (indexers reuse this) |
| `field.md` | `field` |
| `operator.md` | `operator` |
| `namespace-index.md` | `namespace` |

Optional templates that override the fallback chain:

| File | Fallback |
|---|---|
| `enum.md` | `class.md` |
| `event.md` | `field.md` |
| `delegate.md` | `method.md` |

## Partials

Partials live alongside templates in a `partials/` subfolder. They are referenced via `{{>partial-name}}` and expanded inline by the renderer.

Recommended partials (reused by multiple templates):

- `partials/definition.md` — name/namespace/assembly/signature/inheritance block.
- `partials/remarks.md`
- `partials/parameters.md`
- `partials/type-parameters.md`
- `partials/returns.md`
- `partials/exceptions.md`
- `partials/examples.md`
- `partials/applies-to.md`
- `partials/thread-safety.md`
- `partials/see-also.md`
- `partials/members-table.md` — used by `class.md` for constructors/fields/properties/methods/events/operators.

## Tokens

See [../../shared/token-dictionary.md](../../shared/token-dictionary.md) for the full label token list. Plus element fields: `{{name}}`, `{{fullName}}`, `{{namespace}}`, `{{assembly}}`, `{{summary}}`, `{{signature}}`, `{{remarks}}`, `{{codeLanguage}}`, etc.

Conditionals: `{{#if parameters}}...{{/if}}` — used to omit empty sections.

Iteration: `{{#each parameters}}...{{name}}...{{/each}}` — used inside partials.

## `style.yaml`

```yaml
name: msdn
description: Microsoft Learn / MSDN documentation style.
options:
  # Style-level options passed to every template. Arbitrary keys allowed;
  # the renderer exposes them as {{style.<key>}}.
  showAppliesToTable: true
  showThreadSafety: true
  codeFenceInfoString: true
  colors:
    # Hints for HTML format; ignored for markdown.
    accent: "#0078D4"
```
