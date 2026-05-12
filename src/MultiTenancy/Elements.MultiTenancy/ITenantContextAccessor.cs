namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Provides access to the current tenant context.
/// </summary>
/// <example>
/// <code language="csharp">
/// public class TenantAwareHandler
/// {
///     private readonly ITenantContextAccessor _accessor;
///     public TenantAwareHandler(ITenantContextAccessor accessor) =&gt; _accessor = accessor;
///
///     public string? CurrentTenantId =&gt; _accessor.TenantContext?.TenantId;
/// }
/// </code>
/// </example>
public interface ITenantContextAccessor {
    /// <summary>
    /// Gets or sets the current tenant context.
    /// </summary>
    ITenantContext? TenantContext {
        get; set;
    }
}