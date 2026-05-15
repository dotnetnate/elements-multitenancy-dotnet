# {{parent.name}}.{{name}} {{memberLabel.operator}}

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

{{/each}}

{{>applies-to}}

{{>see-also}}
{{/if}}
{{#unless overloads}}
{{summary}}

{{>definition-member}}

{{>parameters}}

{{>returns}}

{{>exceptions}}

{{>remarks}}

{{>examples}}

{{>applies-to}}

{{>see-also}}
{{/unless}}
