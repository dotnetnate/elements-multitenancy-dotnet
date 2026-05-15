# {{parent.name}} {{memberLabel.constructor}}

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

{{>parameters}}

{{>exceptions}}

{{>remarks}}

{{>examples}}

{{>applies-to}}

{{>see-also}}
{{/unless}}
