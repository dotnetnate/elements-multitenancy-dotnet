{{#if examples}}
## {{heading.examples}}

{{#each examples}}
{{#if caption}}**{{caption}}**{{/if}}

```{{language}}
{{code}}
```

{{/each}}
{{/if}}
