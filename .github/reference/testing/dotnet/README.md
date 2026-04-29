# .NET Testing Reference

Deep-dive testing guides specific to .NET/C# projects. These are the **source of truth** for testing standards — the `instructions/testing/` files are compact, agent-optimized derivatives.

## Contents

| File | Scope |
|------|-------|
| `unit-tests.md` | MSTest v3 structure, domain entity tests, handler tests, specification tests |
| `integration-tests.md` | TestContainers, WebApplicationFactory, EF Core, database lifecycle |
| `build-verification-tests.md` | BVT/smoke tests against deployed services, test configuration |
| `http-api-tests.md` | .http file testing, controller unit tests, HTTP status mapping |
| `grpc-api-tests.md` | gRPC service tests, RpcException mapping, GrpcChannel |
| `graphql-api-tests.md` | HotChocolate mutation/query tests, GraphQLException mapping |
| `console-cli-tests.md` | System.CommandLine tests, argument/option verification |
| `performance-tests.md` | BenchmarkDotNet micro-benchmarks, load testing |
| `contract-tests.md` | Proto compatibility, event serialization, Pact |
