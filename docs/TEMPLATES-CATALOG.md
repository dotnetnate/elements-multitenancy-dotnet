# Elements Item Templates Catalog

This catalog lists all `dotnet new` item templates to be implemented for the elements-dotnet libraries.

All template short names are prefixed with `myorg-` for uniqueness. Each template project lives under its respective area folder (e.g., `cqrs/Elements.Cqrs.Templates/`). One template project per area; extension-specific items are included in the area template project.

Destination paths use `{AppName}` for the consuming application's root namespace (e.g., `MyOrg.WorkTracker`).

---

## CQRS — `cqrs/Elements.Cqrs.Templates/`

### myorg-cqrs-command

Creates a Command, CommandHandler, optional Validator, and optional paired test fixture.

| File | Destination |
|------|-------------|
| `{Name}Command.cs` | `{AppName}.Application/Commands/{Entity}/{Name}Command.cs` |
| `{Name}CommandHandler.cs` | `{AppName}.Application/Commands/{Entity}/{Name}CommandHandler.cs` |
| `{Name}CommandValidator.cs` (optional) | `{AppName}.Application/Commands/{Entity}/{Name}CommandValidator.cs` |
| `{Name}CommandHandlerTestFixture.cs` (optional) | `{AppName}.Application.Tests.Unit/Commands/{Entity}/{Name}CommandHandlerTestFixture.cs` |

**Parameters:** `--name`, `--entity`, `--include-validator` (default: true), `--include-test` (default: true)

### myorg-cqrs-query

Creates a Query, QueryHandler, optional Filter, and optional paired test fixture.

| File | Destination |
|------|-------------|
| `{Name}Query.cs` | `{AppName}.Application/Queries/{Name}Query.cs` |
| `{Name}QueryHandler.cs` | `{AppName}.Application/Queries/{Name}QueryHandler.cs` |
| `{Name}Filter.cs` (optional) | `{AppName}.Application/Queries/{Name}Filter.cs` |
| `{Name}QueryHandlerTestFixture.cs` (optional) | `{AppName}.Application.Tests.Unit/Queries/{Name}QueryHandlerTestFixture.cs` |

**Parameters:** `--name`, `--pageable` (default: false), `--include-filter` (default: false), `--include-test` (default: true)

### myorg-cqrs-behavior

Creates a Pipeline Behavior and optional paired test fixture.

| File | Destination |
|------|-------------|
| `{Name}Behavior.cs` | `{AppName}.Application/Behaviors/{Name}Behavior.cs` |
| `{Name}BehaviorTestFixture.cs` (optional) | `{AppName}.Application.Tests.Unit/Behaviors/{Name}BehaviorTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

---

## Application Model — `applicationmodel/Elements.ApplicationModel.Templates/`

### myorg-appmodel-dto

Creates a DTO model record.

| File | Destination |
|------|-------------|
| `{Name}Model.cs` | `{AppName}.Application/Models/{Name}Model.cs` |

**Parameters:** `--name`

### myorg-appmodel-mapper

Creates an AutoMapper profile.

| File | Destination |
|------|-------------|
| `{Name}MappingProfile.cs` | `{AppName}.Application/Mappers/{Name}MappingProfile.cs` |

**Parameters:** `--name`

### myorg-appmodel-integration-event

Creates an integration event record.

| File | Destination |
|------|-------------|
| `{Name}IntegrationEvent.cs` | `{AppName}.Application/IntegrationEvents/{Name}IntegrationEvent.cs` |

**Parameters:** `--name`

### myorg-appmodel-event-handler

Creates a domain event notification handler.

| File | Destination |
|------|-------------|
| `{Name}Handler.cs` | `{AppName}.Application/Events/{Name}Handler.cs` |
| `{Name}HandlerTestFixture.cs` (optional) | `{AppName}.Application.Tests.Unit/Events/{Name}HandlerTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-appmodel-metrics

Creates a business metrics class and tags enum.

| File | Destination |
|------|-------------|
| `{Name}Metrics.cs` | `{AppName}.Application/Metrics/{Name}Metrics.cs` |
| `{Name}MetricTags.cs` | `{AppName}.Application/Metrics/{Name}MetricTags.cs` |

**Parameters:** `--name`

---

## Domain — `domain/Elements.Domain.Templates/`

### myorg-domain-aggregate

Creates an Aggregate Root with Status enum, Repository interface, initial Domain Events, and Specifications.

| File | Destination |
|------|-------------|
| `{Name}.cs` | `{AppName}.Domain/{Name}/{Name}.cs` |
| `{Name}Status.cs` | `{AppName}.Domain/{Name}/{Name}Status.cs` |
| `I{Name}Repository.cs` | `{AppName}.Domain/{Name}/I{Name}Repository.cs` |
| `{Name}Created.cs` | `{AppName}.Domain/{Name}/Events/{Name}Created.cs` |
| `{Name}NameSpecification.cs` | `{AppName}.Domain/{Name}/Specifications/{Name}NameSpecification.cs` |
| `{Name}StatusSpecification.cs` | `{AppName}.Domain/{Name}/Specifications/{Name}StatusSpecification.cs` |
| `{Name}TestFixture.cs` (optional) | `{AppName}.Domain.Tests.Unit/{Name}/{Name}TestFixture.cs` |
| `{Name}SpecificationTestFixture.cs` (optional) | `{AppName}.Domain.Tests.Unit/{Name}/Specifications/{Name}SpecificationTestFixture.cs` |

**Parameters:** `--name`, `--status-values` (default: "Pending,InProgress,Completed,Cancelled"), `--include-test` (default: true)

### myorg-domain-event

Creates a single Domain Event record.

| File | Destination |
|------|-------------|
| `{Name}.cs` | `{AppName}.Domain/{Entity}/Events/{Name}.cs` |

**Parameters:** `--name`, `--entity`

### myorg-domain-specification

Creates a single Specification class.

| File | Destination |
|------|-------------|
| `{Name}Specification.cs` | `{AppName}.Domain/{Entity}/Specifications/{Name}Specification.cs` |

**Parameters:** `--name`, `--entity`

---

## Data — `data/Elements.Data.Templates/`

### myorg-data-repository-ef

Creates an Entity Framework repository implementation and entity configuration.

| File | Destination |
|------|-------------|
| `Ef{Name}Repository.cs` | `{AppName}.Infrastructure/Persistence/Repositories/Ef{Name}Repository.cs` |
| `{Name}Configuration.cs` | `{AppName}.Infrastructure/Persistence/Configurations/{Name}Configuration.cs` |
| `Ef{Name}RepositoryTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Repositories/Ef{Name}RepositoryTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)


**Parameters:** `--name`, `--include-test` (default: true)

### myorg-data-repository-sqlserver

Creates a native SQL Server repository implementation.

| File | Destination |
|------|-------------|
| `SqlServer{Name}Repository.cs` | `{AppName}.Infrastructure/Persistence/Repositories/SqlServer{Name}Repository.cs` |
| `SqlServer{Name}RepositoryTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Repositories/SqlServer{Name}RepositoryTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-data-repository-postgresql

Creates a native PostgreSQL repository implementation.

| File | Destination |
|------|-------------|
| `PostgreSql{Name}Repository.cs` | `{AppName}.Infrastructure/Persistence/Repositories/PostgreSql{Name}Repository.cs` |
| `PostgreSql{Name}RepositoryTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Repositories/PostgreSql{Name}RepositoryTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-data-repository-mongodb

Creates a native MongoDB repository implementation.

| File | Destination |
|------|-------------|
| `Mongo{Name}Repository.cs` | `{AppName}.Infrastructure/Persistence/Repositories/Mongo{Name}Repository.cs` |
| `Mongo{Name}RepositoryTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Repositories/Mongo{Name}RepositoryTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-data-dbcontext

Creates an Entity Framework DbContext.

| File | Destination |
|------|-------------|
| `{Name}DbContext.cs` | `{AppName}.Infrastructure/Persistence/EntityFramework/{Name}DbContext.cs` |

**Parameters:** `--name`

---

## Messaging — `messaging/Elements.Messaging.Templates/`

Includes templates for messaging providers (Kafka, RabbitMQ, AWS SNS).

### myorg-messaging-handler

Creates a message/event handler for a messaging provider.

| File | Destination |
|------|-------------|
| `{Name}Handler.cs` | `{AppName}.Infrastructure/Messaging/{Name}Handler.cs` |
| `{Name}HandlerTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Messaging/{Name}HandlerTestFixture.cs` |

**Parameters:** `--name`, `--provider` (Kafka, RabbitMQ, AwsSns), `--include-test` (default: true)

### myorg-messaging-publisher

Creates a message/event publisher for a messaging provider.

| File | Destination |
|------|-------------|
| `{Name}Publisher.cs` | `{AppName}.Infrastructure/Messaging/{Name}Publisher.cs` |
| `{Name}PublisherTestFixture.cs` (optional) | `{AppName}.Infrastructure.Tests.Unit/Messaging/{Name}PublisherTestFixture.cs` |

**Parameters:** `--name`, `--provider` (Kafka, RabbitMQ, AwsSns), `--include-test` (default: true)

---

## API — `api/Elements.Api.Templates/`

Includes templates for all service host types (HTTP/AspNet, GraphQL, gRPC, Console, MCP, Daemons).

### myorg-api-http-controller

Creates an HTTP/REST controller with contracts (request/response DTOs), mapper profile, validators, and optional test fixture.

| File | Destination |
|------|-------------|
| `{Name}Controller.cs` | `{AppName}.Service.Http/Controllers/{Name}Controller.cs` |
| `Create{Name}Request.cs` | `{AppName}.Service.Http/Contracts/Create{Name}Request.cs` |
| `Create{Name}Response.cs` | `{AppName}.Service.Http/Contracts/Create{Name}Response.cs` |
| `Get{Name}Response.cs` | `{AppName}.Service.Http/Contracts/Get{Name}Response.cs` |
| `Update{Name}Request.cs` | `{AppName}.Service.Http/Contracts/Update{Name}Request.cs` |
| `Update{Name}RequestBody.cs` | `{AppName}.Service.Http/Contracts/Update{Name}RequestBody.cs` |
| `Search{Name}sRequest.cs` | `{AppName}.Service.Http/Contracts/Search{Name}sRequest.cs` |
| `Search{Name}sResponse.cs` | `{AppName}.Service.Http/Contracts/Search{Name}sResponse.cs` |
| `Delete{Name}Request.cs` | `{AppName}.Service.Http/Contracts/Delete{Name}Request.cs` |
| `Get{Name}ByIdRequest.cs` | `{AppName}.Service.Http/Contracts/Get{Name}ByIdRequest.cs` |
| `{Name}HttpMappingProfile.cs` | `{AppName}.Service.Http/Mappers/{Name}HttpMappingProfile.cs` |
| `Create{Name}RequestValidator.cs` | `{AppName}.Service.Http/Validators/Create{Name}RequestValidator.cs` |
| `Update{Name}RequestValidator.cs` | `{AppName}.Service.Http/Validators/Update{Name}RequestValidator.cs` |
| `Update{Name}RequestBodyValidator.cs` | `{AppName}.Service.Http/Validators/Update{Name}RequestBodyValidator.cs` |
| `Delete{Name}RequestValidator.cs` | `{AppName}.Service.Http/Validators/Delete{Name}RequestValidator.cs` |
| `Get{Name}ByIdRequestValidator.cs` | `{AppName}.Service.Http/Validators/Get{Name}ByIdRequestValidator.cs` |
| `Search{Name}sRequestValidator.cs` | `{AppName}.Service.Http/Validators/Search{Name}sRequestValidator.cs` |
| `{Name}ControllerTestFixture.cs` (optional) | `{AppName}.Service.Http.Tests.Unit/Controllers/{Name}ControllerTestFixture.cs` |

**Parameters:** `--name`, `--route-prefix` (default: `/api/v1`), `--include-test` (default: true)

### myorg-api-graphql-type

Creates GraphQL type, input types, query/mutation resolvers, mapper profile, validators, and optional test fixture.

| File | Destination |
|------|-------------|
| `{Name}Type.cs` | `{AppName}.Service.GraphQL/Types/{Name}Type.cs` |
| `Search{Name}sResultType.cs` | `{AppName}.Service.GraphQL/Types/Search{Name}sResultType.cs` |
| `Create{Name}Input.cs` | `{AppName}.Service.GraphQL/Inputs/Create{Name}Input.cs` |
| `Update{Name}Input.cs` | `{AppName}.Service.GraphQL/Inputs/Update{Name}Input.cs` |
| `Search{Name}sInput.cs` | `{AppName}.Service.GraphQL/Inputs/Search{Name}sInput.cs` |
| `{Name}Queries.cs` | `{AppName}.Service.GraphQL/Queries/{Name}Queries.cs` |
| `{Name}Mutations.cs` | `{AppName}.Service.GraphQL/Mutations/{Name}Mutations.cs` |
| `{Name}GraphQLMappingProfile.cs` | `{AppName}.Service.GraphQL/Mappers/{Name}GraphQLMappingProfile.cs` |
| `Create{Name}InputValidator.cs` | `{AppName}.Service.GraphQL/Validators/Create{Name}InputValidator.cs` |
| `Update{Name}InputValidator.cs` | `{AppName}.Service.GraphQL/Validators/Update{Name}InputValidator.cs` |
| `{Name}QueriesTestFixture.cs` (optional) | `{AppName}.Service.GraphQL.Tests.Unit/Queries/{Name}QueriesTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-api-grpc-service

Creates a gRPC service implementation, proto file, mapper profile, validators, and optional test fixture.

| File | Destination |
|------|-------------|
| `{name}.proto` | `{AppName}.Service.Grpc/Protos/{name}.proto` |
| `{Name}GrpcService.cs` | `{AppName}.Service.Grpc/Services/{Name}GrpcService.cs` |
| `{Name}GrpcMappingProfile.cs` | `{AppName}.Service.Grpc/Mappers/{Name}GrpcMappingProfile.cs` |
| `Create{Name}RequestValidator.cs` | `{AppName}.Service.Grpc/Validators/Create{Name}RequestValidator.cs` |
| `Update{Name}RequestValidator.cs` | `{AppName}.Service.Grpc/Validators/Update{Name}RequestValidator.cs` |
| `Delete{Name}RequestValidator.cs` | `{AppName}.Service.Grpc/Validators/Delete{Name}RequestValidator.cs` |
| `Get{Name}ByIdRequestValidator.cs` | `{AppName}.Service.Grpc/Validators/Get{Name}ByIdRequestValidator.cs` |
| `Search{Name}sRequestValidator.cs` | `{AppName}.Service.Grpc/Validators/Search{Name}sRequestValidator.cs` |
| `{Name}GrpcServiceTestFixture.cs` (optional) | `{AppName}.Service.Grpc.Tests.Unit/Services/{Name}GrpcServiceTestFixture.cs` |

**Parameters:** `--name`, `--include-test` (default: true)

### myorg-api-console-command

Creates a console CLI command definition with input DTOs and validators.

| File | Destination |
|------|-------------|
| `Create{Name}CliCommand.cs` | `{AppName}.Service.Console/Commands/Create{Name}CliCommand.cs` |
| `Get{Name}CliCommand.cs` | `{AppName}.Service.Console/Commands/Get{Name}CliCommand.cs` |
| `Search{Name}sCliCommand.cs` | `{AppName}.Service.Console/Commands/Search{Name}sCliCommand.cs` |
| `Delete{Name}CliCommand.cs` | `{AppName}.Service.Console/Commands/Delete{Name}CliCommand.cs` |