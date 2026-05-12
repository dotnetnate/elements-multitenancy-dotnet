namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Default implementation of <see cref="ITenantIdParser"/> that trims whitespace.
/// </summary>
/// <example>
/// <code language="csharp">
/// ITenantIdParser parser = new DefaultTenantIdParser();
/// string? id = parser.Parse("  contoso "); // "contoso"
/// </code>
/// </example>
public sealed class DefaultTenantIdParser : ITenantIdParser {
    /// <inheritdoc/>
    public string? Parse(string? rawTenantId) {
        if (string.IsNullOrWhiteSpace(rawTenantId)) {
            return null;
        }

        return rawTenantId.Trim();
    }
}