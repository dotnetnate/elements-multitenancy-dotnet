# Canonical Documentation Model

Every language-specific extractor produces a single JSON file conforming to this schema. The renderer consumes only this schema, which is why templates are language-agnostic.

## Top-level

```jsonc
{
  "project": "MyLib",
  "language": "dotnet",            // dotnet | java | kotlin | typescript | javascript
  "version": "1.2.3",              // optional — used in "Applies to"
  "assembly": "MyLib",             // language-native container name (dll/jar/module/package)
  "generatedAt": "2026-04-23T00:00:00Z",
  "elements": [ /* Element[] */ ]
}
```

## `Element`

An element represents a documentable entity. The same record shape is used for every `kind`; unused fields are omitted.

```jsonc
{
  "id": "T:MyLib.Foo",              // stable cross-reference id
  "kind": "class",                  // see Kinds
  "name": "Foo",
  "fullName": "MyLib.Foo",
  "namespace": "MyLib",
  "parent": "T:MyLib",              // id of enclosing type/namespace; null for top-level
  "signature": "public sealed class Foo : IFoo",  // language-formatted declaration
  "modifiers": ["public", "sealed"],
  "visibility": "public",           // public | protected | internal | private

  "summary": "One-line description.",
  "remarks": "Longer markdown.",
  "examples": [
    { "caption": "Basic usage", "language": "csharp", "code": "var x = new Foo();" }
  ],

  "parameters": [                   // methods / ctors / indexers / delegates
    { "name": "count", "type": "Int32", "typeId": "T:System.Int32", "summary": "...", "isOptional": false, "defaultValue": null }
  ],
  "typeParameters": [
    { "name": "T", "summary": "...", "constraints": ["class", "new()"] }
  ],
  "returns": { "type": "String", "typeId": "T:System.String", "summary": "..." },
  "exceptions": [
    { "type": "ArgumentNullException", "typeId": "T:System.ArgumentNullException", "summary": "..." }
  ],

  "inheritance": ["T:System.Object"],  // ordered base chain (types only)
  "implements": ["T:System.IFoo"],     // interfaces (types only)
  "derived": ["T:MyLib.Bar"],          // known derived types (types only)

  "members": ["M:MyLib.Foo.Bar", "P:MyLib.Foo.Value"], // ids of direct members (types only)

  "seeAlso": [
    { "text": "String", "href": "System.String.md", "id": "T:System.String" }
  ],

  "appliesTo": [                     // version / framework table
    { "product": "MyLib", "versions": ["1.0", "1.1", "1.2"] }
  ],

  "threadSafety": "This type is thread safe. All members are immutable.",

  "sourceFile": "src/Foo.cs",
  "sourceLine": 42,

  "attributes": ["Serializable", "Obsolete(\"...\")" ],

  "extras": { /* free-form, per-language extension bag */ }
}
```

## `kind` values

Core kinds mapped to template files:

| kind | Typical template | Notes |
|---|---|---|
| `namespace` | `namespace-index.md` | Also used for Java `package`, TS `module`. |
| `class` | `class.md` | |
| `interface` | `class.md` | Reuses the type template. |
| `struct` | `class.md` | |
| `record` | `class.md` | |
| `enum` | `enum.md` | Optional; falls back to `class.md`. |
| `delegate` | `delegate.md` | Optional; falls back to `method.md`. |
| `method` | `method.md` | |
| `constructor` | `constructor.md` | |
| `property` | `property.md` | Also used for indexers. |
| `field` | `field.md` | |
| `event` | `event.md` | Optional; falls back to `field.md`. |
| `operator` | `operator.md` | |
| `extension-method` | `method.md` | |

If a template is missing, the renderer falls back to the indicated fallback; if that is also missing, it emits a warning and skips the element.

## Cross-reference resolution

`id`, `typeId`, `parent`, `inheritance[]`, `implements[]`, and `seeAlso[].id` all use the same id scheme. Renderer converts each id to a relative link based on the output layout.

### Inline cross-reference markers

When the source documentation contains inline `<see cref="X"/>` references (or the equivalent in other languages), the normalizer emits a placeholder marker inside text fields (`summary`, `remarks`, parameter/exception summaries, etc.) rather than resolving the link at extraction time:

```
{{xref:<id>|<fallback-label>}}
```

- `<id>` uses the id format below (e.g. `T:MyLib.Foo`, `M:MyLib.Foo.Bar(System.Int32)`).
- `<fallback-label>` is the display text (from `<see>Label</see>` if provided, otherwise the last name segment). It is used when the renderer cannot resolve the id (unknown / external type), in which case the marker is rendered as inline ``code``.
- The renderer performs a final pass across **all** written output files and rewrites markers to relative markdown links based on the combined id-to-href map of every aggregated project, giving forwards- and backwards-cross-project linking automatically.

**Id format** (adapted from the .NET cref conventions so it is language-agnostic):

- `N:<namespace>` — namespace/package/module
- `T:<fullname>` — type (class, interface, struct, enum, record, delegate)
- `M:<fullname>(<params>)` — method / constructor (ctor uses `#ctor` as the last name segment, consistent with csc XML)
- `P:<fullname>` — property / indexer
- `F:<fullname>` — field / enum member
- `E:<fullname>` — event
- `O:<fullname>` — operator

The language-specific normalizer is responsible for producing ids in this form regardless of the source format.
