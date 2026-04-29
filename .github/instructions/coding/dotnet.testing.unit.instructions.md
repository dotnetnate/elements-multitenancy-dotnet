---
applyTo: "**/*Tests.Unit/**/*.cs, **/*Tests.Unit/**/*.csproj"
---

- Unit test projects must use the `MSTest` test framework and should be created using `dotnet new mstest` template.

- Test classes must be decorated with the `[TestClass]` attribute.
- Test classes must be named {ClassUnderTest}TestFixture, e.g., `WorkItemValidatorTestFixture`.
- The namespace of the test class must be the same as the namespace of the class under test. 
- Test classes must follow the same physical file layout as the project under test, e.g.:
  - `WorkTracker.Domain/WorkItem.cs` → `WorkTracker.Domain.Tests.Unit/WorkItemTestFixture.cs`
- Test projects must have a reference to the project under test and to `MSTest.TestFramework` and `MSTest.TestAdapter` NuGet packages.
- Test methods must be decorated with the `[TestMethod]` attribute.
- Test method names must follow the pattern: `Given_{MethodUnderTest}_Called_When_{Conditions}_Then_{Expected_Result}` (underscore between ALL words).
  - ✅ `Given_Validate_Called_When_Argument0_Is_Null_Then_Returns_False`
  - ❌ `Given_ValidateCalled_When_Argument0IsNull_Then_Returns_False`
  - For compound conditions, use `And` between conditions:
    - ✅ `Given_Validate_Called_When_Argument0_Is_Null_And_Argument1_Is_Valid_Then_Returns_False`
    - ❌ `Given_ValidateCalled_When_Argument0IsNullAndArgument1IsValid_Then_ReturnsFalse`
- Test methods must be `public` and return `void` or `Task` (for async tests).