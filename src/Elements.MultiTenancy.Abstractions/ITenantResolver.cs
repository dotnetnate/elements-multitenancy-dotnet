namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Resolves tenant identifiers from multiple strategies using a strongly-typed context.
/// </summary>
/// <typeparam name="TContext">The type of context used for resolution (e.g., HttpContext).</typeparam>
/// <example>
/// <code language="csharp">
/// ITenantResolver&lt;HttpContext&gt; resolver = serviceProvider.GetRequiredService&lt;ITenantResolver&lt;HttpContext&gt;&gt;();
/// ITenantContext ctx = await resolver.ResolveAsync(httpContext);
/// if (ctx.IsResolved) Console.WriteLine($"Tenant: {ctx.TenantId}");
/// </code>
/// </example>
public interface ITenantResolver<in TContext> {
    /// <summary>
    /// Resolves the tenant identifier from the given context.
    /// </summary>
    /// <param name="context">The resolution context.</param>
    /// <returns>The tenant context if resolved; otherwise, an unresolved context.</returns>
    /// <example>
    /// <code language="csharp">
    /// ITenantContext ctx = await resolver.ResolveAsync(httpContext);
    /// </code>
    /// </example>
    Task<ITenantContext> ResolveAsync(TContext context);
}