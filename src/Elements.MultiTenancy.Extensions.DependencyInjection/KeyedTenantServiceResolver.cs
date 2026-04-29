using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.DependencyInjection;

/// <summary>
/// Implementation of <see cref="ITenantServiceResolver{TService}"/> using keyed DI services.
/// </summary>
/// <typeparam name="TService">The service type.</typeparam>
/// <remarks>
/// This implementation leverages .NET's keyed service support where the tenant ID is used as the service key.
/// This approach has better performance as services are resolved directly from the DI container without
/// additional factory overhead. However, all tenant service instances must be registered upfront.
/// </remarks>
/// <example>
/// <code language="csharp">
/// services.AddKeyedSingleton&lt;IMessagePublisher, KafkaMessagePublisher&gt;("contoso");
/// services.AddKeyedSingleton&lt;IMessagePublisher, RabbitMqMessagePublisher&gt;("fabrikam");
/// services.AddKeyedTenantServiceResolver&lt;IMessagePublisher&gt;();
///
/// var resolver = sp.GetRequiredService&lt;ITenantServiceResolver&lt;IMessagePublisher&gt;&gt;();
/// IMessagePublisher publisher = resolver.Resolve("contoso");
/// </code>
/// </example>
public sealed class KeyedTenantServiceResolver<TService> : ITenantServiceResolver<TService>
    where TService : class {
    private readonly IServiceProvider _serviceProvider;
    private readonly ITenantContextAccessor _tenantContextAccessor;

    /// <summary>
    /// Initializes a new instance of the <see cref="KeyedTenantServiceResolver{TService}"/> class.
    /// </summary>
    /// <param name="serviceProvider">The service provider.</param>
    /// <param name="tenantContextAccessor">The tenant context accessor.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="serviceProvider"/> or <paramref name="tenantContextAccessor"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var resolver = new KeyedTenantServiceResolver&lt;IMessagePublisher&gt;(sp, accessor);
    /// </code>
    /// </example>
    public KeyedTenantServiceResolver(
        IServiceProvider serviceProvider,
        ITenantContextAccessor tenantContextAccessor) {
        _serviceProvider = serviceProvider ?? throw new ArgumentNullException(nameof(serviceProvider));
        _tenantContextAccessor = tenantContextAccessor ?? throw new ArgumentNullException(nameof(tenantContextAccessor));
    }

    /// <inheritdoc/>
    public TService Resolve(string tenantId) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        var service = _serviceProvider.GetKeyedService<TService>(tenantId);

        if (service == null) {
            throw new InvalidOperationException(
                $"No service of type {typeof(TService).Name} is registered for tenant '{tenantId}'.");
        }

        return service;
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