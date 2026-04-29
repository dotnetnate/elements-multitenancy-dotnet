using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.Security.Identity;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Extension methods for configuring multi-tenancy in ASP.NET Core applications.
/// </summary>
/// <example>
/// <code language="csharp">
/// var builder = WebApplication.CreateBuilder(args);
/// builder.Services.AddElementsMultiTenancy(o =>
/// {
///     o.ResolveFromHeader = true;
///     o.ResolveFromClaims = true;
/// });
///
/// var app = builder.Build();
/// app.UseElementsMultiTenancy();
/// app.Run();
/// </code>
/// </example>
public static class ServiceCollectionExtensions {
    /// <summary>
    /// Adds multi-tenancy services with ASP.NET Core resolution strategies.
    /// </summary>
    /// <param name="services">The service collection.</param>
    /// <param name="configure">Optional configuration action for multi-tenancy options.</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// builder.Services.AddElementsMultiTenancy(options =>
    /// {
    ///     options.ResolveFromHeader = true;
    ///     options.ResolveFromClaims = true;
    ///     options.HeaderName = "X-Tenant-Id";
    /// });
    /// </code>
    /// </example>
    public static IServiceCollection AddElementsMultiTenancy(
        this IServiceCollection services,
        Action<MultiTenancyOptions>? configure = null,
        ServiceLifetime lifetime = ServiceLifetime.Singleton) {
        var options = new MultiTenancyOptions();
        configure?.Invoke(options);

        services.Add(new ServiceDescriptor(typeof(MultiTenancyOptions), options));
        services.Add(ServiceDescriptor.Describe(typeof(ITenantContextAccessor), typeof(TenantContextAccessor), lifetime));
        services.Add(ServiceDescriptor.Describe(typeof(ITenantIdParser), typeof(DefaultTenantIdParser), lifetime));

        // Register resolution strategies based on options
        if (options.ResolveFromClaims) {
            services.Add(ServiceDescriptor.Describe(typeof(WellKnownClaimsConfiguration), typeof(WellKnownClaimsConfiguration), lifetime));
            services.Add(ServiceDescriptor.Describe(typeof(ITenantResolutionStrategy<HttpContext>), typeof(ClaimsTenantResolutionStrategy), lifetime));
        }

        if (options.ResolveFromHeader) {
            services.Add(ServiceDescriptor.Describe(typeof(ITenantResolutionStrategy<HttpContext>), typeof(HeaderTenantResolutionStrategy), lifetime));
        }

        if (options.ResolveFromHost) {
            services.Add(ServiceDescriptor.Describe(typeof(ITenantResolutionStrategy<HttpContext>), typeof(HostTenantResolutionStrategy), lifetime));
        }

        if (options.ResolveFromQueryString) {
            services.Add(ServiceDescriptor.Describe(typeof(ITenantResolutionStrategy<HttpContext>), typeof(QueryStringTenantResolutionStrategy), lifetime));
        }

        services.Add(ServiceDescriptor.Describe(typeof(ITenantResolver<HttpContext>), typeof(TenantResolver<HttpContext>), lifetime));

        return services;
    }

    /// <summary>
    /// Adds multi-tenancy services with a GUID-based tenant ID parser.
    /// </summary>
    /// <param name="services">The service collection.</param>
    /// <param name="configure">Optional configuration action for multi-tenancy options.</param>
    /// <param name="lifetime">The service lifetime. Defaults to <see cref="ServiceLifetime.Singleton"/>.</param>
    /// <returns>The service collection for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// // Tenants are identified by GUIDs in headers / claims.
    /// builder.Services.AddElementsMultiTenancyWithGuidParser(options =>
    /// {
    ///     options.HeaderName = "X-Tenant-Id";
    /// });
    /// </code>
    /// </example>
    public static IServiceCollection AddElementsMultiTenancyWithGuidParser(
        this IServiceCollection services,
        Action<MultiTenancyOptions>? configure = null,
        ServiceLifetime lifetime = ServiceLifetime.Singleton) {
        services.AddElementsMultiTenancy(configure, lifetime);

        // Replace the default parser with the GUID parser
        var descriptor = services.FirstOrDefault(d => d.ServiceType == typeof(ITenantIdParser));
        if (descriptor != null) {
            services.Remove(descriptor);
        }
        services.Add(ServiceDescriptor.Describe(typeof(ITenantIdParser), typeof(GuidTenantIdParser), lifetime));

        return services;
    }
}

/// <summary>
/// Extension methods for configuring multi-tenancy middleware.
/// </summary>
/// <example>
/// <code language="csharp">
/// var app = builder.Build();
/// app.UseRouting();
/// app.UseAuthentication();
/// app.UseElementsMultiTenancy(); // resolves tenant before authorization runs
/// app.UseAuthorization();
/// app.MapControllers();
/// </code>
/// </example>
public static class ApplicationBuilderExtensions {
    /// <summary>
    /// Adds the tenant resolution middleware to the application pipeline.
    /// </summary>
    /// <param name="app">The application builder.</param>
    /// <returns>The application builder for chaining.</returns>
    /// <example>
    /// <code language="csharp">
    /// app.UseElementsMultiTenancy();
    /// </code>
    /// </example>
    public static IApplicationBuilder UseElementsMultiTenancy(this IApplicationBuilder app) {
        return app.UseMiddleware<TenantResolutionMiddleware>();
    }
}