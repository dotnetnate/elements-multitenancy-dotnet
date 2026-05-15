---
name: doc-gen-javascript
description: Extract JavaScript API documentation into the doc-gen canonical JSON model. Uses JSDoc with a JSON-emitting template (e.g. `jsdoc -X` or `jsdoc-to-markdown --json`) and normalizes into canonical JSON. Invoked as a subagent by `doc-gen`.
user-invocable: false
---

# doc-gen-javascript — scaffold

> **Status:** scaffold. Implementation is a TODO.

## Planned approach

1. Run `jsdoc -X <entry>` (or `jsdoc-to-markdown --json <entry>`) to produce a parsed JSDoc tree.
2. Invoke `scripts/normalize-javascript.ps1` (TODO) to translate into the canonical model. JS token dictionary matches TS: `module` / `package`.

## Inputs

- `--path <project-root>`
- `--manifest <package.json>`
- `--output-model <file>`

## Current output

Write an empty canonical JSON stub and print the same status line, with `language: "javascript"`.
