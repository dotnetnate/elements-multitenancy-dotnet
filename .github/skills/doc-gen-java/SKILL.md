---
name: doc-gen-java
description: Extract Java API documentation into the doc-gen canonical JSON model. Uses `javadoc` with the `xml-doclet` (https://github.com/cloudblue/xml-doclet) to produce XML, then normalizes to canonical JSON. Invoked as a subagent by `doc-gen`.
user-invocable: false
---

# doc-gen-java — scaffold

> **Status:** scaffold. Implementation is a TODO. The orchestrator will still dispatch this agent; it is expected to return a canonical model with zero elements and the status field populated with the TODO message until implemented.

## Planned approach

1. Locate the javadoc-capable build tool (`mvn`, `gradle`, or raw `javadoc`).
2. Run javadoc with `-doclet com.github.markusbernhardt.xmldoclet.XmlDoclet` (xml-doclet) to produce `javadoc.xml`.
3. Invoke `scripts/normalize-java.ps1` (to be authored) to translate the xml-doclet schema into the canonical model, applying the Java token dictionary (`package` for namespace, `jar` for assembly, etc.).

## Inputs

- `--path <project-root>`
- `--manifest <pom.xml | build.gradle | build.gradle.kts>`
- `--output-model <file>`

## Current output

Print:

```json
{"project":"<name>","modelPath":"<canonical.json>","types":0,"members":0,"status":"doc-gen-java not yet implemented"}
```

Write an empty-but-valid canonical JSON (`{"project":"<name>","language":"java","elements":[]}`) to `--output-model` so the renderer succeeds without errors.
