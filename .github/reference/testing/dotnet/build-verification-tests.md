# .NET Build Verification Test (BVT) Reference

> Comprehensive guide for writing smoke tests / BVTs that verify a deployed service is healthy and functional.

## Project Convention

BVT projects use the suffix `.Tests.Validation`:

```
MyOrg.WorkTracker.Service.Http.Tests.Validation/
MyOrg.WorkTracker.Service.Grpc.Tests.Validation/
MyOrg.WorkTracker.Service.Console.Tests.Validation/
```

## Purpose

BVTs run **after deployment** against a **real running service** to verify:
- The service starts and responds
- Health endpoints return healthy
- Critical happy-path operations succeed
- Configuration is correct for the target environment

## Test Configuration

**Never use localhost defaults.** All service URLs and configuration must come from explicit test configuration — never fall back to hardcoded values.

### Configuration Pattern

```csharp
[TestClass]
public class ServiceHealthBvtTestFixture
{
    private static HttpClient _client = null!;
    private static string _serviceUrl = null!;

    [ClassInitialize]
    public static void ClassSetup(TestContext context)
    {
        var config = new ConfigurationBuilder()
            .AddJsonFile("testsettings.json", optional: false)
            .AddJsonFile($"testsettings.{Environment.GetEnvironmentVariable("TEST_ENVIRONMENT")}.json", optional: true)
            .AddEnvironmentVariables(prefix: "BVT_")
            .Build();

        _serviceUrl = config["ServiceUrl"]
            ?? throw new InvalidOperationException(
                "ServiceUrl is required. Set it in testsettings.json or BVT_ServiceUrl environment variable.");

        _client = new HttpClient { BaseAddress = new Uri(_serviceUrl) };
    }
}
```

### testsettings.json

```json
{
    "ServiceUrl": "",
    "TimeoutSeconds": 30
}
```

The empty string forces explicit configuration — CI pipelines or test runners MUST provide the actual URL. This prevents accidental runs against a wrong environment.

## Test Structure

```csharp
[TestMethod]
public async Task Given_Deployed_Service_When_Health_Check_Called_Then_Returns_Healthy()
{
    var response = await _client.GetAsync("/health");

    response.StatusCode.Should().Be(HttpStatusCode.OK);
    var body = await response.Content.ReadAsStringAsync();
    body.Should().Contain("Healthy");
}

[TestMethod]
public async Task Given_Deployed_Service_When_Get_Projects_Called_Then_Returns_Success()
{
    var response = await _client.GetAsync("/api/projects");

    response.StatusCode.Should().Be(HttpStatusCode.OK);
}
```

## Test Naming

Same convention — underscores between ALL words:

```
Given_Deployed_Service_When_Health_Check_Called_Then_Returns_Healthy
Given_Deployed_Service_When_Get_Projects_Called_Then_Returns_Success
Given_Deployed_Service_When_Create_Project_Called_Then_Returns_Created
```

## gRPC BVTs

```csharp
[TestMethod]
public async Task Given_Deployed_Service_When_Grpc_Health_Check_Called_Then_Returns_Serving()
{
    using var channel = GrpcChannel.ForAddress(_serviceUrl);
    var client = new Health.HealthClient(channel);

    var response = await client.CheckAsync(new HealthCheckRequest());

    response.Status.Should().Be(HealthCheckResponse.Types.ServingStatus.Serving);
}
```

## What to Test

- Health check endpoints (HTTP `/health`, gRPC `Health/Check`)
- Authentication/authorization wiring (if applicable)
- One happy-path CRUD operation per major feature
- OpenAPI/Swagger endpoint availability
- Configuration-dependent features specific to the environment

## What NOT to Test

- Business logic (covered by unit tests)
- Edge cases or error handling (covered by unit and integration tests)
- Data integrity or database state
- Performance or load characteristics
