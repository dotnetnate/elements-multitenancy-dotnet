## {{heading.definition}}

{{namespaceLabel}}: `{{namespace}}`
{{#if assembly}}{{assemblyLabel}}: `{{assembly}}`{{/if}}

```{{codeLanguage}}
{{signature}}
```

{{#if attributes}}
**Attributes:** {{#each attributes}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}
{{/if}}
