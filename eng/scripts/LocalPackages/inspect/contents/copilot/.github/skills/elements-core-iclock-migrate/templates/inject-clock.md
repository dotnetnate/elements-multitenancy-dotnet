# Constructor-injection patch template

For a class that currently has no `IClock`:

```csharp
public sealed class <TypeName>
{
    private readonly IClock _clock;
    // ...other existing fields...

    public <TypeName>(IClock clock /*, other existing parameters... */)
    {
        _clock = clock;
        // ...existing assignments...
    }
}
```

Apply rules:
- Add `IClock clock` as the FIRST parameter if the constructor currently has fewer than 3 parameters; otherwise add it as the LAST parameter (least churn at call sites).
- Update every call site of the constructor in the workspace to pass the clock. For DI-constructed types, no call-site changes are needed.
- If the type has multiple constructors, inject into the primary constructor and route others through it.