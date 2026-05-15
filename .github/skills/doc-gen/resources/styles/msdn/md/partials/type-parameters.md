{{#if typeParameters}}
#### {{heading.typeParameters}}

| Name | Description |
|---|---|
{{#each typeParameters}}| `{{name}}` | {{summary}} |
{{/each}}
{{/if}}
