namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Default implementation of <see cref="ITenantContext"/>.
/// </summary>
/// <example>
/// <code language="csharp">
/// ITenantContext resolved = new TenantContext("contoso");
/// ITenantContext unresolved = TenantContext.Unresolved;
/// Console.WriteLine($"{resolved.TenantId} resolved={resolved.IsResolved}");
/// </code>
/// </example>
public sealed class TenantContext : ITenantContext {
    /// <summary>
    /// Initializes a new instance of the <see cref="TenantContext"/> class.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <exception cref="ArgumentException">
    /// Thrown when <paramref name="tenantId"/> is <c>null</c>, empty, or whitespace.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var ctx = new TenantContext("contoso");
    /// </code>
    /// </example>
    public TenantContext(string tenantId) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        TenantId = tenantId;
        IsResolved = true;
    }

    /// <inheritdoc/>
    public string TenantId {
        get;
    }

    /// <inheritdoc/>
    public bool IsResolved {
        get;
    }

    /// <summary>
    /// Gets a tenant context that represents an unresolved tenant.
    /// </summary>
    public static ITenantContext Unresolved { get; } = new UnresolvedTenantContext();

    private sealed class UnresolvedTenantContext : ITenantContext {
        public string TenantId => string.Empty;
        public bool IsResolved => false;
    }
}