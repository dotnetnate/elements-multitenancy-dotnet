# {{workspace}} — API Reference

{{#if description}}{{description}}

{{/if}}{{#if generatedAt}}_Generated: {{generatedAt}}_

{{/if}}
## Projects

| {{projectColumnLabel}} | Description |
|---|---|
{{#each projects}}| [`{{name}}`]({{href}}) | {{summary}} |
{{/each}}
