# {{name}} {{namespaceLabel}}

{{summary}}

{{#if classes}}
## Classes

| {{typeLabel.class}} | Description |
|---|---|
{{#each classes}}| [{{name}}]({{href}}) | {{summary}} |
{{/each}}
{{/if}}

{{#if interfaces}}
## Interfaces

| {{typeLabel.interface}} | Description |
|---|---|
{{#each interfaces}}| [{{name}}]({{href}}) | {{summary}} |
{{/each}}
{{/if}}

{{#if structs}}
## Structs

| {{typeLabel.struct}} | Description |
|---|---|
{{#each structs}}| [{{name}}]({{href}}) | {{summary}} |
{{/each}}
{{/if}}

{{#if enums}}
## Enums

| {{typeLabel.enum}} | Description |
|---|---|
{{#each enums}}| [{{name}}]({{href}}) | {{summary}} |
{{/each}}
{{/if}}

{{#if delegates}}
## Delegates

| {{typeLabel.delegate}} | Description |
|---|---|
{{#each delegates}}| [{{name}}]({{href}}) | {{summary}} |
{{/each}}
{{/if}}
