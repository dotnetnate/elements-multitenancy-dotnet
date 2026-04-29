namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Configuration options for multi-tenancy resolution.
/// </summary>
/// <example>
/// <code language="csharp">
/// services.AddElementsMultiTenancy(options =>
/// {
///     options.HeaderName = "X-Tenant-Id";
///     options.ClaimType = "tenant_id";
///     options.QueryStringParameterName = "tenant";
///     options.ResolveFromClaims = true;
///     options.ResolveFromHeader = true;
///     options.ResolveFromHost = false;
///     options.ResolveFromQueryString = true;
/// });
/// </code>
/// </example>
public sealed class MultiTenancyOptions {
    /// <summary>
    /// Gets or sets the HTTP header name to check for tenant ID.
    /// </summary>
    public string HeaderName { get; set; } = "X-Tenant-Id";

    /// <summary>
    /// Gets or sets the claim type to check for tenant ID.
    /// </summary>
    public string? ClaimType {
        get; set;
    }

    /// <summary>
    /// Gets or sets the query string parameter name to check for tenant ID.
    /// </summary>
    public string QueryStringParameterName { get; set; } = "tenant";

    /// <summary>
    /// Gets or sets a value indicating whether to resolve tenant from claims.
    /// </summary>
    public bool ResolveFromClaims { get; set; } = true;

    /// <summary>
    /// Gets or sets a value indicating whether to resolve tenant from HTTP headers.
    /// </summary>
    public bool ResolveFromHeader { get; set; } = true;

    /// <summary>
    /// Gets or sets a value indicating whether to resolve tenant from host/subdomain.
    /// </summary>
    public bool ResolveFromHost { get; set; } = true;

    /// <summary>
    /// Gets or sets a value indicating whether to resolve tenant from query string.
    /// </summary>
    public bool ResolveFromQueryString { get; set; } = false;

    /// <summary>
    /// Gets or sets the host parsing function for extracting tenant from host name.
    /// Default extracts the first subdomain (e.g., "tenant" from "tenant.example.com").
    /// </summary>
    public Func<string, string?> HostParser { get; set; } = DefaultHostParser;

    private static string? DefaultHostParser(string host) {
        if (string.IsNullOrWhiteSpace(host)) {
            return null;
        }

        // Remove port if present
        var hostWithoutPort = host.Split(':')[0];

        var parts = hostWithoutPort.Split('.');

        // If at least 3 parts (e.g., tenant.example.com), return the first part
        if (parts.Length >= 3) {
            return parts[0];
        }

        return null;
    }
}