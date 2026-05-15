# {{name}} {{typeLabel.interface}}

{{summary}}

{{>definition}}

{{>type-parameters}}

{{>remarks}}

{{>examples}}

{{#if derived}}
## Derived

{{#each derived}}- [{{text}}]({{href}}){{#unless @last}}
{{/unless}}{{/each}}

{{/if}}

{{#if properties}}
## {{heading.properties}}

{{>members-table-properties}}
{{/if}}

{{#if methods}}
## {{heading.methods}}

{{>members-table-methods}}
{{/if}}

{{#if events}}
## {{heading.events}}

{{>members-table-events}}
{{/if}}

{{#if extensionMethods}}
## {{heading.extensionMethods}}

{{>members-table-extension-methods}}
{{/if}}

{{>applies-to}}

{{>see-also}}
