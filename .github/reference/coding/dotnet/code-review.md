# .NET Code Review Checklist

> Reference for reviewing C# code in this repository. Use as a systematic checklist during pull request reviews.

## ALWAYS FOLLOW THESE STEPS FIRST

- [ ] Delete the `/src/test-results` folder if it exists to remove any previous test results and coverage reports. This must be the first step before building and testing. WWhen deleting the folders, no errors should be displayed if the folder does not exist.
- [ ] Verify that the `dotnet-coverage` dotnet tool is installed globally. If it is not, install the tool globally with the command: `dotnet tool install --global dotnet-coverage`
- [ ] Verify that the `dotnet-reportgenerator-globaltool`  dotnet tool is installed globally. If not, install the tool globally with the command: `dotnet tool install --global dotnet-reportgenerator-globaltool`
- [ ] Perform a `dotnet clean` on the solution to ensure a clean state before building and testing.
- [ ] Build the solution using `dotnet build` and ensure that there are no build errors or warnings.

## Architecture & Layer Compliance

- [ ] **Dependency rule respected** — Domain has no references to Application, Infrastructure, or Service layers
- [ ] **Infrastructure implements Domain interfaces** — Repositories implement `I*Repository` from Domain
- [ ] **No cross-service references** — Service projects reference Application and Infrastructure, not each other
- [ ] **Correct project placement** — New types are in the right project (entity → Domain, handler → Application, repository → Infrastructure)

## Type Design

- [ ] **Sealed by default** — All concrete classes/records are `sealed` unless designed as base classes
- [ ] **Correct type choice** — Immutable data carriers use `sealed record`; mutable/behavioral types use `sealed class`
- [ ] **Primary constructors on records** — Commands, queries, events, models use primary constructor syntax
- [ ] **`private set` on entity properties** — No public setters on domain entity state
- [ ] **Static `Create()` factory** — Domain entities use factory methods, not public constructors
- [ ] **Private parameterless constructor** — Present on entities for EF Core materialization

## Naming

- [ ] **`_camelCase` for private fields** — Including readonly fields
- [ ] **PascalCase for everything else** — Methods, properties, constants, classes
- [ ] **No `Async` suffix** — Unless both sync and async versions coexist
- [ ] **`cancellationToken` spelled out** — Never `ct`, `token`, or `cts`
- [ ] **`TestFixture` suffix on test classes** — Not `Tests` or `Test`
- [ ] **`Given_When_Then` test methods** — Descriptive scenario-based names. Always use an underscore between all words.
- [ ] **Namespace matches folder path** — Exactly

## Error Handling

- [ ] **Result pattern for business failures** — `Result<T>.Failure(error)`, never exceptions
- [ ] **Typed errors used** — `ResourceNotFoundError`, `InvalidOperationError`, etc. — not raw `Error`
- [ ] **App errors in `WorkTrackerErrors` class** — Static factory methods, not inline construction
- [ ] **Domain guards throw exceptions** — `InvalidOperationException` for state violations, `ArgumentException` for invalid inputs
- [ ] **No swallowed exceptions** — Every catch block logs or re-throws
- [ ] **Guard clauses at method entry** — Fail fast before executing logic

## CQRS

- [ ] **Handler extends correct base** — `CommandHandler<TCommand, TResult>` or `QueryHandler<TQuery, TResult>`
- [ ] **HandleImpl / GetResult override** — Not `Handle` directly
- [ ] **Existence checks before mutations** — Validate preconditions return failures, not exceptions
- [ ] **SaveChangesAsync after mutations** — Via `IUnitOfWork`, not `DbContext` directly
- [ ] **Integration events after save** — Published explicitly after `SaveChangesAsync()`
- [ ] **Metrics recorded on success** — `BusinessMetrics` methods called for trackable operations

## Domain Model

- [ ] **State transitions validated** — Behavior methods check current status before mutation
- [ ] **Domain events raised** — Creation and significant state changes raise events via `RaiseDomainEvent()`
- [ ] **Specifications for query predicates** — Separate `sealed class` per predicate, composed with `.And()` / `.Or()`
- [ ] **No logic in entity constructors** — Validation only in `Create()` factory or guards in behavior methods
- [ ] **Collection encapsulation** — Private `List<T>` + public `IReadOnlyCollection<T>`

## Persistence (EF Core)

- [ ] **Entity configuration in `IEntityTypeConfiguration<T>`** — Separate file per entity
- [ ] **Concurrency token configured** — `.IsConcurrencyToken()` on `Version` or `UpdatedAt`
- [ ] **Soft-delete query filter** — `.HasQueryFilter(e => !e.IsDeleted)` where applicable
- [ ] **Repository delegates to DbContext** — No raw SQL unless specifically justified
- [ ] **Repository is `sealed`** — One repository per aggregate root

## Validation

- [ ] **Two-layer validation present** — Service-layer validator + command validator if both layers involved
- [ ] **FluentValidation rules complete** — All command properties have appropriate rules
- [ ] **No manual validation in handlers** — Handled by `ValidationBehavior` pipeline

## Mapping

- [ ] **AutoMapper profile exists** — For new entity/model at each layer boundary
- [ ] **`ForCtorParam` for record mapping** — Records use constructor parameters
- [ ] **No mapping in handlers** — Use `IMapper`, not manual property copying
- [ ] **Mapping is Tested** — Mapping between layers, be it through Automapper, manual, or other mapping methods, is tested to confirm expectations in type mapping.

## Documentation

- [ ] **XML `<summary>` on public members** — Classes, records, methods, properties
- [ ] **`<param>` on record constructors** — For primary constructor parameters
- [ ] **`<inheritdoc />` for overrides** — Where base class documents the contract
- [ ] **No commented-out code** — Remove dead code, don't comment it

## Testing

- [ ] **Test exists for new behavior** — Every public behavior has a test
- [ ] **MSTest Assert.* used** — Standard MSTest assertions for all test verification
- [ ] **Mocks set up minimally** — Only mock what is needed for the specific test
- [ ] **Verify interactions** — `A.CallTo().MustHaveHappened()` for important side effects
- [ ] **Test both success and failure paths** — Happy path alone is insufficient
- [ ] **No test interdependence** — Each test can run independently
- [ ] **Configurable Tests** — Utilize [DataRow] and similar capabilities of the MSTest framework to allow data-driven tests
- [ ] Set the output path of dotnet test results to `/src/test-results`.
  - [ ] Run all unit tests (projects ending in Tests.Unit) and report any failures and any projects that do not have test coverage of at least 90%.
  - When running the `dotnet test` command, ensure that the following options are set:
    - [ ] Use the `--collect "Code Coverage"` option to collect code coverage data.
    - [ ] Specify the runsettings file by passing `--settings codecoverage.runsettings` to the command.
    - [ ] Set the output path for test results to `/src/test-results` by passing `--logger "trx;LogFileName=./test_results.trx"` to the command.
    - [ ] Set the results directory to `/src/test-results` by passing `--results-directory ./test-results` to the command.
  - [ ] Run the `dotnet-coverage` tool to merge and generate the coverage report:
    - [ ] Use the `merge` command to combine coverage results from all test projects.
    - [ ] Set the output format to XML by passing `xml` to the `--output-format` option.
    - [ ] Set the output path to `/src/test-results/coverage.xml` by passing `./test-results/coverage.xml` to the `--output` option.
    - [ ] Set the input path to the test results by passing `./test-results/**/*.coverage` to the command.
    - [ ] Create a table summarizing the test coverage results by analyzing the generated coverage report in `/src/test-results/coverage.xml`.
    - [ ] For each project, include the project name, total lines of code, lines covered by tests, and overall coverage percentage.
    - RULE: If the `/src/test-results/coverage.xml` file is too large, read the file in chunks to avoid memory issues and process the file in its entirety.

## Style

- [ ] **File-scoped namespace** — Not block-scoped
- [ ] **Expression-bodied for single expressions** — Properties, simple methods
- [ ] **Pattern matching for null/type checks** — `is null`, `is not null`, `is not Type`
- [ ] **Modern collection expressions** — `[]` not `new List<T>()`
- [ ] **String interpolation** — Not `string.Format()`
- [ ] **Member ordering followed** — Fields → constructors → properties → factories → methods

## Security

- [ ] **Authorization behavior in pipeline** — Pipeline behavior checks authorization
- [ ] **Input validated at boundary** — FluentValidation on all public-facing inputs
- [ ] **No secrets in code** — Connection strings, API keys via configuration/secrets
- [ ] **Parameterized queries** — EF Core LINQ, no string concatenation for queries

## Observability

- [ ] **Structured logging** — Named placeholders: `{OrderId}` not `object.ToString()`
- [ ] **No PII logged** — Credentials, tokens, account numbers, personal data stay out of logs. Flag any findings of this as CRITICAL.
- [ ] **Metrics for business operations** — Counters/histograms via `BusinessMetrics`
- [ ] **CancellationToken propagated** — Passed to all async calls in the chain

## Report Format

- RULE: When providing findings, be specific and actionable. Provide code snippets or examples where applicable to illustrate your points.
- RULE: Do not provide commentary on code review aspects in which you find no issues.
- RULE: When generating the findings report, order the findings by category in the following order. Use an H2 heading for each category:
  - Code Correctness Issues
  - Code Quality Issues
  - Architectural Issues
  - Error Handling Issues
  - Design Patterns Issues
  - Documentation Issues
  - Performance Issues
  - Security Sssues
  - Testing and Coverage Issues
  - Any other categories defined in this review file
RULE: - For each finding, include the list of all applicable projects, files, and lines.
