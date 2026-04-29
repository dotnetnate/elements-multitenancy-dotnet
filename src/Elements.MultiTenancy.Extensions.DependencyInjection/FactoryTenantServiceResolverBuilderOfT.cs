namespace MyOrg.Elements.MultiTenancy.DependencyInjection;

/// <summary>
/// Builder for configuring factory-based tenant service resolver.
/// </summary>
/// <typeparam name="TService">The service type.</typeparam>
/// <example>
/// <code language="csharp">
/// services.AddFactoryTenantServiceResolver&lt;IMessagePublisher&gt;(b =&gt; b
///     .ForTenant("contoso", sp =&gt; new KafkaMessagePublisher(...))
///     .ForTenant("fabrikam", sp =&gt; new RabbitMqMessagePublisher(...)));
/// </code>
/// </example>
public sealed class FactoryTenantServiceResolverBuilder<TService>
    where TService : class {
    private readonly FactoryTenantServiceResolver<TService> _resolver;

    internal FactoryTenantServiceResolverBuilder(FactoryTenantServiceResolver<TService> resolver) {
        _resolver = resolver;
    }

    /// <summary>
    /// Registers a factory for a specific tenant.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <param name="factory">The factory function to create the service instance.</param>
    /// <returns>The builder for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// builder.ForTenant("contoso", sp =&gt; new KafkaMessagePublisher(sp.GetRequiredService&lt;KafkaSettings&gt;()));
    /// </code>
    /// </example>
    public FactoryTenantServiceResolverBuilder<TService> ForTenant(
        string tenantId,
        Func<IServiceProvider, TService> factory) {
        _resolver.RegisterFactory(tenantId, factory);
        return this;
    }
}