# .NET Reference Documents

Deep-dive reference material for .NET development in this repository.

For distilled rules auto-injected into editors, see `../../../instructions/coding/dotnet.instructions.md`.

## Files

| File | Purpose |
|------|---------|
| `style-guide.md` | File structure, naming conventions, type declarations, member ordering, expression style, collections, strings, null handling, XML documentation, guard clauses |
| `design-principles.md` | CQRS pipeline flow, Result pattern API, Error hierarchy, DDD building blocks (Entity, AggregateRoot, Specification, Domain Events), validation pipeline, repository/UoW, mapping, DI patterns, observability, template conditionals |
| `code-review.md` | Systematic checklist for reviewing .NET pull requests — architecture, type design, naming, error handling, CQRS, domain model, persistence, validation, mapping, testing, style, security, observability |
| `quality-attributes.md` | Performance (pagination, efficient queries, compiled expressions, async), security (authorization pipeline, input validation, identity, data protection), observability (metrics, tracing, health checks, logging), resilience (optimistic concurrency, cancellation, error isolation) |
