namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// A tenant ID parser that normalizes values to GUIDs.
/// </summary>
/// <example>
/// <code language="csharp">
/// ITenantIdParser parser = new GuidTenantIdParser();
/// string? id = parser.Parse("7f8d4c3b-1a2e-4d5f-9a0b-1234567890ab");
/// // id == "7f8d4c3b-1a2e-4d5f-9a0b-1234567890ab"
/// string? bad = parser.Parse("not-a-guid"); // null
/// </code>
/// </example>
public sealed class GuidTenantIdParser : ITenantIdParser {
    /// <inheritdoc/>
    public string? Parse(string? rawTenantId) {
        if (string.IsNullOrWhiteSpace(rawTenantId)) {
            return null;
        }

        if (Guid.TryParse(rawTenantId, out var guid)) {
            return guid.ToString("D"); // Standard format: 00000000-0000-0000-0000-000000000000
        }

        return null;
    }
}