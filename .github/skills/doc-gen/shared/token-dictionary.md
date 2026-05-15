# Token Dictionary

Templates use generic `{{tokenLabel}}` tokens for nouns that differ across languages. The renderer resolves them from `shared/token-dictionary.json` (authoritative) — this file is the human-readable view.

## Label tokens

| Token | dotnet | java | kotlin | typescript | javascript |
|---|---|---|---|---|---|
| `{{namespaceLabel}}` | Namespace | Package | Package | Module | Module |
| `{{assemblyLabel}}` | Assembly | Jar | Module | Package | Package |
| `{{typeLabel.class}}` | Class | Class | Class | Class | Class |
| `{{typeLabel.interface}}` | Interface | Interface | Interface | Interface | Interface |
| `{{typeLabel.struct}}` | Struct | — | — | — | — |
| `{{typeLabel.record}}` | Record | Record | Data Class | — | — |
| `{{typeLabel.enum}}` | Enum | Enum | Enum | Enum | — |
| `{{typeLabel.delegate}}` | Delegate | — | — | Function Type | — |
| `{{memberLabel.method}}` | Method | Method | Function | Method / Function | Method / Function |
| `{{memberLabel.property}}` | Property | — | Property | Property / Accessor | Property / Accessor |
| `{{memberLabel.field}}` | Field | Field | Property (val/var) | Field | Field |
| `{{memberLabel.event}}` | Event | — | — | — | — |
| `{{memberLabel.operator}}` | Operator | — | Operator | — | — |
| `{{memberLabel.constructor}}` | Constructor | Constructor | Constructor | Constructor | Constructor |
| `{{memberLabel.constants}}` | Fields | Fields | Constants | Constants | Constants |
| `{{section.appliesTo}}` | Applies to | Available since | Available since | Available since | Available since |
| `{{section.threadSafety}}` | Thread Safety | Thread Safety | Thread Safety | — | — |
| `{{section.remarks}}` | Remarks | Details | Details | Remarks | Remarks |

Per-language overrides live in `shared/token-dictionary.json`. The orchestrator passes `language` to the renderer, which selects the active column.

## Escape rules

- All tokens are HTML-escaped by default when `format=html`.
- Markdown format escapes pipe characters inside table cells.
- MDX format additionally escapes `{`, `}`, and `<` outside fenced code blocks.
