---
name: elements-validation-add-boundary
description: Adds boundary-level Elements.Validation `IValidationService` validation to a controller action, minimal-API endpoint, or MediatR handler. Injects `IValidationService`, inserts `await _validator.ValidateAsync(dto, cancellationToken)` as the first executable line, returns `Result.Failure(...)` or HTTP 400 on failure, and adds an integration test asserting rejection. USE FOR any "validate at boundary", "add validation gate", "validate the request" request.
argument-hint: "<EndpointOrHandlerType>"
user-invocable: true
---

# elements-validation-add-boundary

## Interview

Invoke the `vscode_askQuestions` tool with the following questions in a SINGLE call (multiple questions per call — do not call the tool repeatedly):

| header | question | options (★ = recommended) |
|---|---|---|
| `target-type` | Type or file path of the controller, minimal-API delegate, or `IRequestHandler<TRequest, TResponse>` implementation to harden? | _free text_ |
| `failure-shape` | How should validation failure be returned? | `auto-detect` ★, `Result.Failure`, `Results.BadRequest(ProblemDetails)`, `Results.BadRequest(new { errors })` |

Skip `target-type` when supplied as an argument. For `failure-shape = auto-detect`: MVC controllers and minimal-API endpoints map to `Results.BadRequest(...)` (using `ProblemDetails` when `AddProblemDetails` is registered); MediatR handlers returning `Result<T>` map to `Result<T>.Failure(...)`; handlers returning plain `T` stop and report — the signature must change first.

## Procedure

1. **Resolve target.** Locate the file. If multiple matches exist for the supplied type name, stop and report.

2. **Add the package** if not already referenced. Run, in the target project's directory:

   ```bash
   dotnet add package Elements.Validation
   ```

   If the workspace has `Directory.Packages.props`, run `dotnet add package Elements.Validation --no-restore` and surface a TODO to add the matching `<PackageVersion Include="Elements.Validation" Version="..."/>` entry.

3. **Inject `IValidationService`.** Add a constructor parameter `IValidationService validator` and a `private readonly IValidationService _validator;` field. Guard with `ArgumentNullException.ThrowIfNull(validator);`. If the target is a minimal-API lambda or `static` method, stop and emit a TODO directing the user to convert it to a typed delegate handler first.

4. **Insert the validation gate** as the FIRST executable line of the handler body:

   ```csharp
   var validation = await _validator.ValidateAsync(request, cancellationToken);
   if (!validation.IsValid)
   {
       return <failure-shape>;
   }
   ```

   Apply this exhaustive substitution table for `<failure-shape>`:

   | failure-shape | Replacement |
   |---|---|
   | `Result.Failure` | `Result<<TResponse>>.Failure(validation.Errors);` |
   | `Results.BadRequest(ProblemDetails)` | `Results.ValidationProblem(validation.Errors.ToDictionary(e => e.PropertyName, e => new[] { e.ErrorMessage }));` |
   | `Results.BadRequest(new { errors })` | `Results.BadRequest(new { errors = validation.Errors });` |

5. **Generate the negative test** in the matching `*.Tests.Integration` (or `*.Tests.Unit` for handler-only) project:

   ```csharp
   [TestMethod]
   public async Task Returns_BadRequest_when_request_is_invalid()
   {
       var invalid = new <TRequest>();

       var result = await /* invoke the endpoint or handler */;

       Assert.AreEqual(<expected-failure>, /* extract */);
   }
   ```

   If no matching test project exists, emit a TODO instead.

6. **Build.** Run `dotnet build` on the target project and capture the output tail for the report.

## Report

After completion, emit a markdown summary:

- Files created: `<count>` ([file](path))
- Files modified: `<count>` ([file](path))
- Target type: `<TargetType>`
- Failure shape: `<shape>`
- Packages installed: `<list>`
- Build status: `<succeeded|failed>` (output: `<truncated tail>`)
- Outstanding TODOs: `<list>` — each as a workspace-relative file link with line number

## Constraints

- Never throw `ValidationException` on a validation failure — the gate ALWAYS returns a typed failure. A Roslyn analyzer for this rule is planned — see [docs/analyzer-roadmap.md#elv0001](../../../docs/analyzer-roadmap.md#elv0001).
- Never duplicate the same validation check in downstream domain services.
- Always name the cancellation parameter `cancellationToken` — never `ct`, `token`, or `cts`.
- If the target DTO has no rules at all, surface a warning recommending the `elements-validation-scaffold-validator` skill.