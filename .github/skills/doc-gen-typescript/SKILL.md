---
name: doc-gen-typescript
description: Extract TypeScript API documentation into the doc-gen canonical JSON model. Uses TypeDoc (`typedoc --json`) and normalizes into canonical JSON. Invoked as a subagent by `doc-gen`.
user-invocable: false
---

# doc-gen-typescript — scaffold

> **Status:** scaffold. Implementation is a TODO.

## Planned approach

1. Ensure `typedoc` is available (local devDependency or `npx --yes typedoc`).
2. Run `typedoc --json <out.json> <entry>` against the project entry points.
3. Invoke `scripts/normalize-typescript.ps1` (TODO) to translate the TypeDoc reflection JSON into the canonical model. The TS token dictionary maps `namespace`→`module`, `assembly`→`package`.

## Inputs

- `--path <project-root>`
- `--manifest <package.json | tsconfig.json>`
- `--output-model <file>`

## Current output

Write an empty canonical JSON stub and print the same status line, with `language: "typescript"`.
