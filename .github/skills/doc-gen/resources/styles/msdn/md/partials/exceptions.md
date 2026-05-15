{{#if exceptions}}
#### {{heading.exceptions}}

| Exception | Condition |
|---|---|
{{#each exceptions}}| {{xref:{{type}}|}} | {{summary}} |
{{/each}}
{{/if}}
