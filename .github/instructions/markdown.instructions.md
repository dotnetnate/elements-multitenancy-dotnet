---
applyTo: "**/*.md"
---

# Markdown Instructions

This file contains instructions for writing markdown files in the project. It applies to all markdown files (`**/*.md`).

## General Guidelines

- Use clear and concise language.
- Follow the project's style guide for formatting and tone.

## Formatting

- Follow all markdown best practices for headings, lists, code blocks, and links.
- Generate table columns with the appropriate number of dashes (`---`) to ensure proper rendering.
- Generate table columns with a space to the right and left of the pipe character, as appropriate, to avoid markdownlint error MD060/table-column-style.
- Use fenced code blocks with language identifiers for syntax highlighting.
- Use relative links for cross-referencing other markdown files in the project.
- [CRITICAL] Markdown files must pass markdownlint validation in order to be considered compliant with project standards. The only exception is for markdown files that are intended for agent consumption and are not meant to be human-readable (e.g., certain prompt templates or structured data files). For all other markdown files, ensure that they adhere to markdownlint rules to maintain consistency and readability across the project.

- [RULE] When generating fenced code blocks, always specify a language. If none can be reasonably inferred, use `text`.

- [RULE] If a large number of MD060 errors are reported (>10), use the following regular expressions to find and replace them in a batch at once, in this order:
  - Find: `^(\|)(?=-)` Replace: `$1 `
  - Find: `-(\|)(?=-)` Replace: `- $1 `
  - Find: `-(\|)$` Replace: `- $1`

## Mermaid Diagrams

- Use `flowchart` (not `graph`) for all flow and relationship diagrams.
- For diagram direction, prefer `TD` for hierarchies and processes with multiple branches; use `LR` for linear pipelines, lifecycles, and authority chains.
- Use `<br/>` for line breaks within node labels — never `\n`, which renders as a literal string.
- Use stadium nodes `([...])` for terminal states: entry points, outputs, handoffs, and final outcomes. Use rectangle nodes `[...]` for process steps and intermediate states. Use diamond nodes `{...}` for decisions.
- Apply `classDef` and `class` statements for all diagrams with more than two nodes. Do not leave diagrams unstyled.
- Use this color palette consistently:

  | Role | Fill | Stroke | Text |
  |--- | --- | --- | --- |
  | Process / phase | `#dbeafe` | `#3b82f6` | `#1e3a5f` |
  | Positive outcome / output | `#dcfce7` | `#22c55e` | `#14532d` |
  | Decision / gate | `#fef3c7` | `#f59e0b` | `#78350f` |
  | Entry point / story / current item | `#ede9fe` | `#8b5cf6` | `#4c1d95` |
  | Refinement / feedback / warning | `#fef3c7` | `#f59e0b` | `#78350f` |
  | Risk / external dependency | `#fef3c7` | `#f59e0b` | `#78350f` |
  | Human / authoritative | `#fef3c7` | `#f59e0b` | `#78350f` |
  | Critic | `#dbeafe` | `#3b82f6` | `#1e3a5f` |
  | Work Agent | `#dcfce7` | `#22c55e` | `#14532d` |

- Use `stroke-width:2px` for standard nodes and `stroke-width:3px` to highlight the focal node (e.g., "this folder" in hierarchy diagrams).
- Use `<i>...</i>` within node labels to add secondary descriptive text (e.g., `"Themes<br/><i>this folder</i>"`).
- Use subgraphs to group logically related nodes when a diagram has distinct phases or levels. Apply `direction LR` inside subgraphs when their internal flow is horizontal.
- Edge labels should be short (1–5 words). Use `-->|label|` syntax for labeled edges.
- Assign role-based colors when nodes map to different agent types or disciplines (e.g., backend = blue, frontend = green, test = amber).