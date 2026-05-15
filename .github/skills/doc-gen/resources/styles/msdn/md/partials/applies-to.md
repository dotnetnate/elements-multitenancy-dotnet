## {{section.appliesTo}}

{{#if appliesTo}}
| Product | Versions |
|---|---|
{{#each appliesTo}}| {{product}} | {{#each versions}}{{this}}{{#unless @last}}, {{/unless}}{{/each}} |
{{/each}}
{{/if}}
{{#unless appliesTo}}
| Product | Versions |
|---|---|
| `{{assembly}}` | latest |
{{/unless}}
