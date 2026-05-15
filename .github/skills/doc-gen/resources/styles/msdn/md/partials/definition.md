## {{heading.definition}}

{{namespaceLabel}}: `{{namespace}}`
{{#if assembly}}{{assemblyLabel}}: `{{assembly}}`{{/if}}

```{{codeLanguage}}
{{signature}}
```

{{#if inheritance}}
**Inheritance:** {{#each inheritance}}{{xref:{{id}}|{{text}}}}{{#unless @last}} → {{/unless}}{{/each}} → **{{name}}**
{{/if}}

{{#if implements}}
**Implements:** {{#each implements}}{{xref:{{id}}|{{text}}}}{{#unless @last}}, {{/unless}}{{/each}}
{{/if}}

{{#if attributes}}
**Attributes:** {{#each attributes}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}
{{/if}}
