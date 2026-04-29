namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Represents a strategy for resolving tenant identifiers from a strongly-typed context.
/// </summary>
/// <typeparam name="TContext">The type of context used for resolution (e.g., HttpContext).</typeparam>
/// <example>
/// <code language="csharp">
/// public sealed class StaticTenantResolutionStrategy : ITenantResolutionStrategy&lt;HttpContext&gt;
/// {
///     public int Priority =&gt; 100;
///     public Task&lt;string?&gt; ResolveAsync(HttpContext context) =&gt; Task.FromResult&lt;string?&gt;("contoso");
/// }
/// </code>
/// </example>
public interface ITenantResolutionStrategy<in TContext> {
    /// <summary>
    /// Gets the priority of this strategy. Lower values are attempted first.
    /// </summary>
    int Priority {
        get;
    }

    /// <summary>
    /// Attempts to resolve a tenant identifier from the given context.
    /// </summary>
    /// <param name="context">The resolution context.</param>
    /// <returns>The raw tenant identifier if resolved; otherwise, null.</returns>
    /// <example>
    /// <code language="csharp">
    /// string? raw = await strategy.ResolveAsync(httpContext);
    /// </code>
    /// </example>
    Task<string?> ResolveAsync(TContext context);
}