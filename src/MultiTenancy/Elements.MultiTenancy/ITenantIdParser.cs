namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Parses and normalizes tenant identifiers.
/// </summary>
/// <example>
/// <code language="csharp">
/// public sealed class UpperCaseTenantIdParser : ITenantIdParser
/// {
///     public string? Parse(string? rawTenantId) =&gt;
///         string.IsNullOrWhiteSpace(rawTenantId) ? null : rawTenantId.Trim().ToUpperInvariant();
/// }
/// </code>
/// </example>
public interface ITenantIdParser {
    /// <summary>
    /// Parses and normalizes a tenant identifier from a raw string value.
    /// </summary>
    /// <param name="rawTenantId">The raw tenant identifier.</param>
    /// <returns>The normalized tenant identifier, or null if parsing fails.</returns>
    /// <example>
    /// <code language="csharp">
    /// ITenantIdParser parser = new DefaultTenantIdParser();
    /// string? id = parser.Parse("  contoso "); // "contoso"
    /// </code>
    /// </example>
    string? Parse(string? rawTenantId);
}