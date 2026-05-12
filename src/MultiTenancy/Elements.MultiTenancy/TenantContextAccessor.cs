namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Default implementation of <see cref="ITenantContextAccessor"/> using AsyncLocal storage.
/// </summary>
/// <example>
/// <code language="csharp">
/// services.AddSingleton&lt;ITenantContextAccessor, TenantContextAccessor&gt;();
/// // Middleware sets the value once per request:
/// accessor.TenantContext = new TenantContext("contoso");
/// </code>
/// </example>
public sealed class TenantContextAccessor : ITenantContextAccessor {
    private static readonly AsyncLocal<ITenantContext?> _tenantContext = new();

    /// <inheritdoc/>
    public ITenantContext? TenantContext {
        get => _tenantContext.Value;
        set => _tenantContext.Value = value;
    }
}