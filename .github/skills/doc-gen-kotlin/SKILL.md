---
name: doc-gen-kotlin
description: Extract Kotlin API documentation into the doc-gen canonical JSON model. Uses Dokka with a JSON/HTML output, then normalizes into canonical JSON. Invoked as a subagent by `doc-gen`.
user-invocable: false
---

# doc-gen-kotlin — scaffold

> **Status:** scaffold. Implementation is a TODO.

## Planned approach

1. Invoke Dokka via Gradle (`./gradlew dokkaHtml` or `dokkaGfm`) or the standalone Dokka CLI.
2. Prefer a machine-readable Dokka output (HTML + structured JSON side-car, or the `dokka-base` JSON model).
3. Invoke `scripts/normalize-kotlin.ps1` (TODO) to translate into canonical JSON, applying the Kotlin token dictionary (`package` for namespace, `module` / `artifact` for assembly).

## Inputs

- `--path <project-root>`
- `--manifest <build.gradle.kts>`
- `--output-model <file>`

## Current output

Write an empty canonical JSON stub and print the same status line as `doc-gen-java`, with `language: "kotlin"`.
