using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.MultiTenancy;
using System.Collections.Concurrent;

namespace MyOrg.Elements.MultiTenancy.DependencyInjection;

/// <summary>
/// Implementation of <see cref="ITenantServiceResolver{TService}"/> using a factory-based registry.
/// </summary>
/// <typeparam name="TService">The service type.</typeparam>
/// <remarks>
/// This implementation uses a registry of factory functions to create or retrieve service instances per tenant.
/// This approach is more flexible than keyed DI as services can be registered on-demand and factories can
/// create instances dynamically based on tenant-specific configuration. However, it has slightly lower
/// performance compared to keyed DI due to the factory invocation overhead.
/// </remarks>
/// <example>
/// <code language="csharp">
/// services.AddFactoryTenantServiceResolver&lt;IMessagePublisher&gt;(b =&gt;
///     b.ForTenant("contoso", sp =&gt; new KafkaMessagePublisher(sp.GetRequiredService&lt;KafkaSettings&gt;())));
///
/// var resolver = sp.GetRequiredService&lt;ITenantServiceResolver&lt;IMessagePublisher&gt;&gt;();
/// IMessagePublisher publisher = resolver.Resolve("contoso");
/// </code>
/// </example>
public sealed class FactoryTenantServiceResolver<TService> : ITenantServiceResolver<TService>
    where TService : class {
    private readonly ConcurrentDictionary<string, Func<IServiceProvider, TService>> _factories;
    private readonly IServiceProvider _serviceProvider;
    private readonly ITenantContextAccessor _tenantContextAccessor;

    /// <summary>
    /// Initializes a new instance of the <see cref="FactoryTenantServiceResolver{TService}"/> class.
    /// </summary>
    /// <param name="serviceProvider">The service provider.</param>
    /// <param name="tenantContextAccessor">The tenant context accessor.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="serviceProvider"/> or <paramref name="tenantContextAccessor"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var resolver = new FactoryTenantServiceResolver&lt;IMessagePublisher&gt;(sp, accessor);
    /// </code>
    /// </example>
    public FactoryTenantServiceResolver(
        IServiceProvider serviceProvider,
        ITenantContextAccessor tenantContextAccessor) {
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
        _tenantContextAccessor = tenantContextAccessor ?? throw new ArgumentNullException(nameof(tenantContextAccessor));
        _factories = new ConcurrentDictionary<string, Func<IServiceProvider, TService>>(StringComparer.OrdinalIgnoreCase);
    }

    /// <summary>
    /// Registers a factory for a specific tenant.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <param name="factory">The factory function to create the service instance.</param>
    /// <exception cref="ArgumentException">
    /// Thrown when <paramref name="tenantId"/> is <c>null</c>, empty, or whitespace.
    /// </exception>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="factory"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// resolver.RegisterFactory("contoso", sp =&gt; new KafkaMessagePublisher(sp.GetRequiredService&lt;KafkaSettings&gt;()));
    /// </code>
    /// </example>
    public void RegisterFactory(string tenantId, Func<IServiceProvider, TService> factory) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        if (factory == null) {
            throw new ArgumentNullException(nameof(factory));
        }

        _factories[tenantId] = factory;
    }

    /// <inheritdoc/>
    public TService Resolve(string tenantId) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        if (!_factories.TryGetValue(tenantId, out var factory)) {
            throw new InvalidOperationException(
                $"No service factory of type {typeof(TService).Name} is registered for tenant '{tenantId}'.");
        }

        return factory(_serviceProvider);
    }

    /// <inheritdoc/>
    public TService ResolveCurrent() {
        var tenantContext = _tenantContextAccessor.TenantContext;

        if (tenantContext == null || !tenantContext.IsResolved) {
            throw new InvalidOperationException(
                "Cannot resolve service for current tenant: tenant context is not available or unresolved.");
        }

        return Resolve(tenantContext.TenantId);
    }
}