# Test fixture template for IClock

When the test class news up the SUT directly:

```csharp
public sealed class <TypeName>Tests
{
    private static readonly DateTimeOffset _fixedNow = new(2025, 1, 1, 0, 0, 0, TimeSpan.Zero);

    private static IClock CreateClock(DateTimeOffset? at = null)
    {
        var clock = Substitute.For<IClock>();
        clock.UtcNow.Returns(at ?? _fixedNow);
        clock.LocalNow.Returns((at ?? _fixedNow).ToLocalTime());
        return clock;
    }

    private <TypeName> CreateSut(IClock? clock = null)
        => new(clock ?? CreateClock() /*, other test deps */);
}
```

If the project does not reference `NSubstitute`, use the mocking library
already in use (`Moq`, `FakeItEasy`). Detect by scanning `*.Tests.*.csproj`
files for `<PackageReference Include="NSubstitute" .../>` / `Moq` / `FakeItEasy`.
If none is present, generate a `FrozenClock` test double class once in the
project''s `TestSupport/` folder and reuse it across tests.