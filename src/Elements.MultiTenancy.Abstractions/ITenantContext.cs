namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Represents the context for a tenant in a multi-tenant application.
/// </summary>
/// <example>
/// <code language="csharp">
/// public class OrderService
/// {
///     public OrderService(ITenantContextAccessor accessor)
///     {
///         ITenantContext? ctx = accessor.TenantContext;
///         if (ctx is { IsResolved: true })
///         {
///             Console.WriteLine($"Operating on tenant {ctx.TenantId}");
///         }
///     }
/// }
/// </code>
/// </example>
public interface ITenantContext {
    /// <summary>
    /// Gets the unique identifier for the tenant.
    /// </summary>
    string TenantId {
        get;
    }

    /// <summary>
    /// Gets a value indicating whether a tenant has been resolved.
    /// </summary>
    bool IsResolved {
        get;
    }
}