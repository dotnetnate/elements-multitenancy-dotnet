# .NET Console CLI Test Reference

> Guide for testing System.CommandLine CLI commands in the WorkTracker Console service.

## Unit Tests

Test CLI command creation, argument/option definitions, and handler invocation:

```csharp
[TestClass]
public class CreateProjectCliCommandTestFixture
{
    [TestMethod]
    public void Given_Service_Provider_When_Create_Called_Then_Returns_Command_With_Correct_Name()
    {
        // Arrange
        var services = new ServiceCollection();
        // Register required dependencies
        var serviceProvider = services.BuildServiceProvider();

        // Act
        var command = CreateProjectCliCommand.Create(serviceProvider);

        // Assert
        command.Should().NotBeNull();
        command.Name.Should().Be("create-project");
    }

    [TestMethod]
    public void Given_Create_Project_Command_When_Inspected_Then_Has_Required_Arguments()
    {
        var services = new ServiceCollection();
        var serviceProvider = services.BuildServiceProvider();
        var command = CreateProjectCliCommand.Create(serviceProvider);

        command.Arguments.Should().Contain(a => a.Name == "name");
    }

    [TestMethod]
    public void Given_Create_Project_Command_When_Inspected_Then_Has_Description_Option()
    {
        var services = new ServiceCollection();
        var serviceProvider = services.BuildServiceProvider();
        var command = CreateProjectCliCommand.Create(serviceProvider);

        command.Options.Should().Contain(o => o.Name == "description");
    }
}
```

## Handler Tests

Test command handlers with mocked pipeline:

```csharp
[TestMethod]
public async Task Given_Valid_Arguments_When_Handler_Invoked_Then_Pipeline_Receives_Command()
{
    // Arrange
    var pipelineMock = new Mock<ICqrsPipeline>();
    pipelineMock
        .Setup(p => p.Execute<CreateProjectCommand, Result<ProjectModel>>(
            It.IsAny<CreateProjectCommand>(), It.IsAny<CancellationToken>()))
        .ReturnsAsync(Result<ProjectModel>.Success(new ProjectModel { Name = "Test" }));

    // Act — invoke handler directly with test args

    // Assert
    pipelineMock.Verify(p => p.Execute<CreateProjectCommand, Result<ProjectModel>>(
        It.Is<CreateProjectCommand>(c => c.Name == "Test"),
        It.IsAny<CancellationToken>()), Times.Once);
}
```

## Test Naming

Underscores between ALL words:

```
Given_Service_Provider_When_Create_Called_Then_Returns_Command_With_Correct_Name
Given_Valid_Arguments_When_Handler_Invoked_Then_Pipeline_Receives_Command
Given_Invalid_Arguments_When_Handler_Invoked_Then_Outputs_Error_Message
```

## What to Test

- CLI command creation and naming
- Command argument and option definitions
- Command handler invocation with mock pipeline
- Output formatting for success and error results

## What NOT to Test

- System.CommandLine framework behavior (parsing, help generation)
- Console I/O directly (use `IConsole` abstraction if testing output)
