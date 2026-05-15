---
applyTo: "**"
---

# General Coding Guidelines

These guidelines apply to all code in this repository regardless of language or framework.

## Principles

- **SOLID** — Single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion
- **DRY** — Extract shared logic; never copy-paste blocks of code
- **YAGNI** — Don't build features speculatively; implement what is needed now
- **Least Surprise** — Code should behave as a reader would expect from its name and signature
- **Fail Fast** — Validate inputs at the boundary; surface errors immediately rather than propagating bad state

## Error Handling

- Use the Result pattern for expected failures — never throw exceptions for business-logic outcomes
- Throw exceptions only for truly exceptional / programmer-error conditions (null refs, argument violations)
- Never swallow exceptions silently — at minimum log at `Warning` level
- Include context in error messages: what was attempted, what went wrong, and any relevant identifiers
- Define typed errors — avoid raw strings for error classification

## Logging & Observability

- Use structured logging with named placeholders: `_logger.LogInformation("Processing {OrderId}", orderId)`
- Never log sensitive data (credentials, PII, tokens)
- Prefer `ILogger<T>` scoped to the owning class
- Use appropriate log levels: `Trace` for flow, `Debug` for diagnostics, `Information` for business events, `Warning` for recoverable issues, `Error` for failures, `Critical` for fatal
- Instrument public-facing operations with metrics and tracing

## Security

- Validate all external input — never trust data from HTTP requests, message queues, or file imports
- Use parameterized queries or ORMs — never build SQL from string concatenation
- Keep secrets out of source: use environment variables, secret managers, or vaults
- Apply least-privilege: services and database connections should have minimal required permissions
- Apply authorization checks at the application boundary (pipeline behaviors, middleware)

## Code Organization

- One concept per file — avoid cramming unrelated types into a single file
- Group by feature/domain concept, not by technical role
- Namespace must match folder path
- Keep files under ~300 lines; extract collaborators when growing beyond this
- Order members consistently within a type (see language-specific guidelines)

## Dependencies

- Prefer constructor injection — avoid service locator or static access to DI containers
- Depend on abstractions (`I*` interfaces) at layer boundaries
- Follow the dependency rule: inner layers must not reference outer layers
- Register dependencies in dedicated extension methods per layer (`AddApplicationServices`, `AddInfrastructureServices`)

## Testing

- Every public behavior should have a corresponding test
- Tests should be deterministic — no dependency on wall-clock time, network, or shared mutable state
- Use descriptive test names that state the scenario and expected outcome
- Use MSTest Assert.* for assertions
- Mock only what you own — don't mock framework or third-party types you don't control

## Documentation

- Document public APIs with language-appropriate doc comments (XML in C#, JSDoc in TypeScript)
- Keep comments why-focused — explain intent and trade-offs, not what the code literally does
- README files at project root should explain purpose, setup, and key decisions
- Architecture Decision Records (ADRs) for significant design choices

## Git & Change Hygiene

- Write clear, imperative commit messages: `Add project archival validation`
- Keep commits focused — one logical change per commit
- Do not commit generated files, build artifacts, or secrets
- Prefer small, reviewable pull requests over large monolithic changesets

## Performance Defaults

- Prefer pagination over unbounded queries — always enforce a maximum page size
- Use `async`/`await` for I/O-bound operations — never block on async code
- Prefer streaming over buffering for large data sets
- Cache only when measured; premature caching adds complexity without evidence of benefit
