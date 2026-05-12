namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Resolves tenant-specific service implementations.
/// </summary>
/// <typeparam name="TService">The service type.</typeparam>
/// <example>
/// <code language="csharp">
/// ITenantServiceResolver&lt;IMessagePublisher&gt; resolver =
///     sp.GetRequiredService&lt;ITenantServiceResolver&lt;IMessagePublisher&gt;&gt;();
///
/// IMessagePublisher publisher = resolver.Resolve("contoso");
/// IMessagePublisher current   = resolver.ResolveCurrent();
/// </code>
/// </example>
public interface ITenantServiceResolver<out TService> where TService : class {
    /// <summary>
    /// Resolves a service instance for the specified tenant.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <returns>The service instance for the tenant.</returns>
    /// <example>
    /// <code language="csharp">
    /// IMessagePublisher publisher = resolver.Resolve("contoso");
    /// </code>
    /// </example>
    TService Resolve(string tenantId);

    /// <summary>
    /// Resolves a service instance for the current tenant context.
    /// </summary>
    /// <returns>The service instance for the current tenant.</returns>
    /// <example>
    /// <code language="csharp">
    /// IMessagePublisher publisher = resolver.ResolveCurrent();
    /// </code>
    /// </example>
    TService ResolveCurrent();
}