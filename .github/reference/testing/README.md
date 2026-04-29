# Testing Reference Documents

Deep-dive reference material for testing practices in this repository.

For distilled rules auto-injected into editors, see `../../instructions/testing/*.instructions.md`.
To regenerate instruction files from these references, see `../../prompts/agentize.prompt.md`.

## Reference Files

| File | Purpose |
|------|---------|
| `general.md` | Testing stack, project naming, MSTest configuration, test class structure, naming conventions, assertion patterns with MSTest Assert.*, mock patterns with FakeItEasy, test data strategies, what to test vs skip |
| `test-data-generation.md` | Data generation strategies — inline constants, factory methods, reflection for protected properties, builder pattern, real dependencies over mocks, file-scoped test utilities, anti-patterns to avoid |
| `web-frontend-tests.md` | TypeScript/Playwright E2E testing — project structure, config, custom fixtures, page objects, selectors, assertions |

### .NET-Specific (`dotnet/`)

| File | Purpose |
|------|---------|
| `dotnet/unit-tests.md` | MSTest v3 structure, domain entity tests, handler tests, specification tests, configurable tests |
| `dotnet/integration-tests.md` | TestContainers, WebApplicationFactory, EF Core, database lifecycle, test data management |
| `dotnet/build-verification-tests.md` | BVT/smoke tests against deployed services, test configuration (no localhost defaults) |
| `dotnet/http-api-tests.md` | .http file testing, controller unit tests, HTTP status mapping, integration tests |
| `dotnet/grpc-api-tests.md` | gRPC service tests, RpcException mapping, GrpcChannel, health checks |
| `dotnet/graphql-api-tests.md` | HotChocolate mutation/query tests, GraphQLException mapping |
| `dotnet/console-cli-tests.md` | System.CommandLine tests, argument/option verification |
| `dotnet/performance-tests.md` | BenchmarkDotNet micro-benchmarks, load testing |
| `dotnet/contract-tests.md` | Proto compatibility, event serialization, Pact |

## Instruction Files (Auto-Injected)

| File | Applies To |
|------|-----------|
| `../../instructions/testing/unit-tests.instructions.md` | `*.Tests.Unit/**/*.cs` |
| `../../instructions/testing/integration-tests.instructions.md` | `*.Tests.Integration/**/*.cs` |
| `../../instructions/testing/build-verification-tests.instructions.md` | `*.Tests.Validation/**/*.cs` |
| `../../instructions/testing/http-api-tests.instructions.md` | `*.Service.Http.Tests.*/**/*.cs` |
| `../../instructions/testing/grpc-api-tests.instructions.md` | `*.Service.Grpc.Tests.*/**/*.cs` |
| `../../instructions/testing/graphql-api-tests.instructions.md` | `*.Service.GraphQL.Tests.*/**/*.cs` |
| `../../instructions/testing/console-cli-tests.instructions.md` | `*.Service.Console.Tests.*/**/*.cs` |
| `../../instructions/testing/performance-tests.instructions.md` | `*performance*/**/*.cs`, `*benchmark*/**/*.cs` |
| `../../instructions/testing/contract-tests.instructions.md` | `*contract*/**/*.cs`, `*pact*/**/*.cs` |
| `../../instructions/testing/web-frontend-tests.instructions.md` | `*e2e*/**/*.ts`, `*playwright*/**/*.ts`, `*.spec.ts` |
