---
applyTo: "**/*.Service.Console.Tests.*/**/*.cs"
---

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Service_Provider_When_Create_Then_Returns_Command_With_Correct_Name`
❌ `Given_ServiceProvider_When_Create_Then_ReturnsCommandWithCorrectName`
RULE: Test fixture class → `{CliCommand}TestFixture`

## What to Test

✅ CLI command creation and naming
✅ Command argument and option definitions
✅ Handler invocation with mock `ICqrsPipeline`
✅ Output formatting for success and error results

## What NOT to Test

❌ System.CommandLine framework behavior (parsing, help generation)
❌ Console I/O — use `IConsole` abstraction if testing output

## Assertions

RULE: MSTest Assert.* exclusively — use Assert.AreEqual(), Assert.IsTrue(), Assert.ThrowsException<>() etc.
RULE: `Assert.IsTrue(result.IsSuccess())` / `Assert.AreEqual("expected", result.Value!.Name)`
RULE: Exception → `Assert.ThrowsException<T>(() => ...)`
RULE: Async exception → `await Assert.ThrowsExceptionAsync<T>(async () => ...)`
RULE: Collections → `Assert.AreEqual(1, collection.Count)` / `Assert.IsInstanceOfType<T>(item)`

## Mocking

RULE: Mock only what you own — `IWorkItemRepository`, `IUnitOfWork`, `IMapper`, `ICqrsPipeline`
NEVER: Mock `DbContext`, `HttpClient`, `GrpcChannel`, or third-party libraries
RULE: Use real `MapperConfiguration` with real profiles for mapping tests

## Deep-Dive

→ `.github/reference/testing/general.md`
→ `.github/reference/testing/dotnet/console-cli-tests.md`
