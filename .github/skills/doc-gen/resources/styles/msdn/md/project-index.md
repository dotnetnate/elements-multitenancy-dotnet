# {{project}}

{{#if assembly}}**{{assemblyLabel}}:** `{{assembly}}`
{{/if}}{{#if version}}**Version:** `{{version}}`
{{/if}}

{{#if hasClasses}}
## {{heading.classes}}

| Name | Description |
|---|---|
{{#each classes}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
{{#if hasInterfaces}}
## {{heading.interfaces}}

| Name | Description |
|---|---|
{{#each interfaces}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
{{#if hasStructs}}
## {{heading.structs}}

| Name | Description |
|---|---|
{{#each structs}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
{{#if hasRecords}}
## {{heading.records}}

| Name | Description |
|---|---|
{{#each records}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
{{#if hasEnums}}
## {{heading.enums}}

| Name | Description |
|---|---|
{{#each enums}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
{{#if hasDelegates}}
## {{heading.delegates}}

| Name | Description |
|---|---|
{{#each delegates}}| [`{{fullName}}`]({{href}}) | {{summary}} |
{{/each}}

{{/if}}
