# {{parent.name}}.{{name}} {{memberLabel.method}}

{{#if overloads}}
{{summary}}

## {{heading.definition}}

{{namespaceLabel}}: `{{namespace}}`
{{#if assembly}}{{assemblyLabel}}: `{{assembly}}`{{/if}}

## Overloads

| Overload | Description |
|---|---|
{{#each overloads}}| `{{signatureShort}}` | {{summary}} |
{{/each}}

{{#each overloads}}

## `{{signatureShort}}`

{{summary}}

```csharp
{{signature}}
```

{{#if typeParameters}}
#### Type Parameters

| Name | Description |
|---|---|
{{#each typeParameters}}| `{{name}}` | {{summary}} |
{{/each}}
{{/if}}

{{#if parameters}}
#### Parameters

| Name | Type | Description |
|---|---|---|
{{#each parameters}}| `{{name}}` | `{{type}}` | {{summary}} |
{{/each}}
{{/if}}

{{#if returns}}
#### Returns

| Type | Description |
|---|---|
| `{{returns.type}}` | {{returns.summary}} |
{{/if}}

{{#if implements}}
#### Implements

{{#each implements}}- {{xref:{{id}}|{{text}}}}
{{/each}}
{{/if}}

{{#if exceptions}}
#### Exceptions

| Exception | Condition |
|---|---|
{{#each exceptions}}| {{xref:{{type}}|}} | {{summary}} |
{{/each}}
{{/if}}

{{#if remarks}}
### Remarks

{{remarks}}
{{/if}}

{{#if examples}}
### Examples

{{#each examples}}
{{#if caption}}**{{caption}}**{{/if}}

```{{language}}
{{code}}
```

{{/each}}
{{/if}}

{{/each}}

{{>applies-to}}

{{>see-also}}
{{/if}}
{{#unless overloads}}
{{summary}}

{{>definition-member}}

{{>type-parameters}}

{{>parameters}}

{{>returns}}

{{#if implements}}
#### {{heading.implements}}

{{#each implements}}- {{xref:{{id}}|{{text}}}}
{{/each}}
{{/if}}

{{>exceptions}}

{{>remarks}}

{{>examples}}

{{>applies-to}}

{{>see-also}}
{{/unless}}
