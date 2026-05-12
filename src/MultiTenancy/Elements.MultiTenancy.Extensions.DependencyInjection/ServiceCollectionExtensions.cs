using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using MyOrg.Elements.Configuration;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.DependencyInjection;

/// <summary>
/// Extension methods for configuring tenant-specific service resolution.
/// </summary>
/// <example>
/// <code language="csharp">
/// services.AddKeyedTenantServiceResolver&lt;IMessagePublisher&gt;();
/// services.AddFactoryTenantServiceResolver&lt;IReportRenderer&gt;(b =&gt;
///     b.ForTenant("contoso", sp =&gt; new HtmlReportRenderer()));
/// services.AddTenantOptions&lt;ReportSettings&gt;(configuration, "Reports");
/// services.AddPolymorphicTenantService&lt;IMessagePublisher&gt;(configuration, "Messaging", b =&gt;
/// {
///     b.AddProvider&lt;KafkaMessagePublisher, KafkaSettings&gt;("Kafka");
///     b.AddProvider&lt;RabbitMqMessagePublisher, RabbitMqSettings&gt;("RabbitMQ");
/// });
/// services.AddConfigurationTenantStore&lt;TenantSettings&gt;();
/// </code>
/// </example>
public static class ServiceCollectionExtensions {
    /// <summary>
    /// Adds a keyed tenant service resolver for the specified service type.
    /// Use this when all tenant service instances can be registered upfront with the DI container.
    /// </summary>
    /// <typeparam name="TService">The service type.</typeparam>
    /// <param name="services">The service collection.</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <remarks>
    /// Keyed DI approach provides better performance as services are resolved directly from the container.
    /// Register tenant services using: services.AddKeyedSingleton&lt;TService&gt;("tenantId", implementation).
    /// </remarks>
    /// <example>
    /// <code language="csharp">
    /// services.AddKeyedSingleton&lt;IMessagePublisher, KafkaMessagePublisher&gt;("contoso");
    /// services.AddKeyedTenantServiceResolver&lt;IMessagePublisher&gt;();
    /// </code>
    /// </example>
    public static IServiceCollection AddKeyedTenantServiceResolver<TService>(this IServiceCollection services, ServiceLifetime lifetime = ServiceLifetime.Singleton)
        where TService : class {
        services.TryAdd(ServiceDescriptor.Describe(typeof(ITenantServiceResolver<TService>), typeof(KeyedTenantServiceResolver<TService>), lifetime));
        return services;
    }

    /// <summary>
    /// Adds a factory-based tenant service resolver for the specified service type.
    /// Use this when tenant services need to be created dynamically or based on runtime configuration.
    /// </summary>
    /// <typeparam name="TService">The service type.</typeparam>
    /// <param name="services">The service collection.</param>
    /// <param name="configure">Action to configure tenant-specific factories.</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <remarks>
    /// Factory approach is more flexible but has slightly lower performance compared to keyed DI.
    /// Factories can create instances dynamically based on tenant-specific configuration loaded at runtime.
    /// </remarks>
    /// <example>
    /// <code language="csharp">
    /// services.AddFactoryTenantServiceResolver&lt;IMessagePublisher&gt;(b =&gt; b
    ///     .ForTenant("contoso", sp =&gt; new KafkaMessagePublisher(...))
    ///     .ForTenant("fabrikam", sp =&gt; new RabbitMqMessagePublisher(...)));
    /// </code>
    /// </example>
    public static IServiceCollection AddFactoryTenantServiceResolver<TService>(
        this IServiceCollection services,
        Action<FactoryTenantServiceResolverBuilder<TService>>? configure = null,
        ServiceLifetime lifetime = ServiceLifetime.Singleton)
        where TService : class {
        services.TryAdd(new ServiceDescriptor(typeof(ITenantServiceResolver<TService>), sp => {
            var tenantContextAccessor = sp.GetRequiredService<ITenantContextAccessor>();
            var resolver = new FactoryTenantServiceResolver<TService>(sp, tenantContextAccessor);

            var builder = new FactoryTenantServiceResolverBuilder<TService>(resolver);
            configure?.Invoke(builder);

            return resolver;
        }, lifetime));
        return services;
    }

    /// <summary>
    /// Registers tenant-specific options from configuration.
    /// Each tenant's options are bound as named options (using the tenant ID as the name)
    /// and exposed via <see cref="TenantOptions{TOptions}"/>.
    /// </summary>
    /// <typeparam name="TOptions">The options type.</typeparam>
    /// <param name="services">The service collection.</param>
    /// <param name="configuration">The configuration root.</param>
    /// <param name="sectionName">The options section name within each tenant's configuration.</param>
    /// <param name="tenantsSection">The configuration section containing tenant definitions. Defaults to "Tenants".</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// // appsettings.json: { "Tenants": { "contoso": { "Reports": { "LogoUrl": "..." } } } }
    /// services.AddTenantOptions&lt;ReportSettings&gt;(configuration, "Reports");
    /// // Inject TenantOptions&lt;ReportSettings&gt; and read .Value for the current tenant.
    /// </code>
    /// </example>
    public static IServiceCollection AddTenantOptions<TOptions>(
        this IServiceCollection services,
        IConfiguration configuration,
        string sectionName,
        string tenantsSection = "Tenants",
        ServiceLifetime lifetime = ServiceLifetime.Singleton)
        where TOptions : class {
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentException.ThrowIfNullOrWhiteSpace(sectionName);

        var tenantsConfig = configuration.GetSection(tenantsSection);

        foreach (var tenantSection in tenantsConfig.GetChildren()) {
            var tenantId = tenantSection.Key;
            var optionsSection = tenantSection.GetSection(sectionName);

            if (optionsSection.Exists()) {
                services.Configure<TOptions>(tenantId, optionsSection);
            }
        }

        services.TryAdd(ServiceDescriptor.Describe(typeof(TenantOptions<TOptions>), typeof(TenantOptions<TOptions>), lifetime));
        return services;
    }

    /// <summary>
    /// Registers polymorphic tenant services whose implementations are determined by per-tenant configuration.
    /// Each tenant can use a different provider (e.g., tenant A uses Kafka, tenant B uses RabbitMQ)
    /// with its own settings, resolved via keyed DI.
    /// </summary>
    /// <typeparam name="TService">The service abstraction type.</typeparam>
    /// <param name="services">The service collection.</param>
    /// <param name="configuration">The configuration root.</param>
    /// <param name="sectionName">The service section name within each tenant's configuration (e.g., "Messaging").</param>
    /// <param name="configure">Action to register provider implementations using <see cref="PolymorphicServiceBuilder{TService}"/>.</param>
    /// <param name="tenantsSection">The configuration section containing tenant definitions. Defaults to "Tenants".</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <remarks>
    /// <para>
    /// Expected configuration shape:
    /// <code>
    /// {
    ///   "Tenants": {
    ///     "tenant-a": { "Messaging": { "Provider": "Kafka", "Settings": { "BootstrapServers": "..." } } },
    ///     "tenant-b": { "Messaging": { "Provider": "RabbitMQ", "Settings": { "Host": "..." } } }
    ///   }
    /// }
    /// </code>
    /// </para>
    /// </remarks>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="configuration"/> or <paramref name="configure"/> is <c>null</c>.
    /// </exception>
    /// <exception cref="ArgumentException">
    /// Thrown when <paramref name="sectionName"/> is <c>null</c>, empty, or whitespace.
    /// </exception>
    /// <exception cref="InvalidOperationException">
    /// Thrown when a tenant section is missing the required <c>Provider</c> entry.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// services.AddPolymorphicTenantService&lt;IMessagePublisher&gt;(configuration, "Messaging", b =&gt;
    /// {
    ///     b.AddProvider&lt;KafkaMessagePublisher, KafkaSettings&gt;("Kafka");
    ///     b.AddProvider&lt;RabbitMqMessagePublisher, RabbitMqSettings&gt;("RabbitMQ");
    /// });
    /// </code>
    /// </example>
    public static IServiceCollection AddPolymorphicTenantService<TService>(
        this IServiceCollection services,
        IConfiguration configuration,
        string sectionName,
        Action<PolymorphicServiceBuilder<TService>> configure,
        string tenantsSection = "Tenants",
        ServiceLifetime lifetime = ServiceLifetime.Singleton)
        where TService : class {
        ArgumentNullException.ThrowIfNull(configuration);
        ArgumentException.ThrowIfNullOrWhiteSpace(sectionName);
        ArgumentNullException.ThrowIfNull(configure);

        var builder = new PolymorphicServiceBuilder<TService>();
        configure(builder);

        var tenantsConfig = configuration.GetSection(tenantsSection);

        foreach (var tenantSection in tenantsConfig.GetChildren()) {
            var tenantId = tenantSection.Key;
            var serviceSection = tenantSection.GetSection(sectionName);

            if (!serviceSection.Exists()) {
                continue;
            }

            var providerName = serviceSection["Provider"]
                ?? throw new InvalidOperationException(
                    $"'Provider' not specified in '{tenantsSection}:{tenantId}:{sectionName}'.");

            var settingsSection = serviceSection.GetSection("Settings");

            builder.RegisterKeyedService(
                services,
                providerName,
                tenantId,
                settingsSection.Exists() ? settingsSection : null);
        }

        services.AddKeyedTenantServiceResolver<TService>(lifetime);
        return services;
    }

    /// <summary>
    /// Adds a configuration-based tenant store for the specified configuration type.
    /// </summary>
    /// <typeparam name="TConfiguration">The tenant configuration type. Must have a parameterless constructor.</typeparam>
    /// <param name="services">The service collection.</param>
    /// <param name="tenantsSection">The configuration section containing tenant definitions. Defaults to "Tenants".</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// services.AddConfigurationTenantStore&lt;TenantSettings&gt;();
    /// var store = sp.GetRequiredService&lt;ITenantStore&lt;TenantSettings&gt;&gt;();
    /// </code>
    /// </example>
    public static IServiceCollection AddConfigurationTenantStore<TConfiguration>(
        this IServiceCollection services,
        string tenantsSection = "Tenants",
        ServiceLifetime lifetime = ServiceLifetime.Singleton)
        where TConfiguration : class, new() {
        services.TryAdd(new ServiceDescriptor(typeof(ITenantStore<TConfiguration>), sp =>
            new ConfigurationTenantStore<TConfiguration>(
                sp.GetRequiredService<IConfiguration>(),
                tenantsSection), lifetime));

        return services;
    }
}