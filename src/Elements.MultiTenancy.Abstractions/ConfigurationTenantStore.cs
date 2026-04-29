using Microsoft.Extensions.Configuration;

namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Configuration-based implementation of <see cref="ITenantStore{TConfiguration}"/>.
/// Reads tenant information and configuration from IConfiguration.
/// </summary>
/// <typeparam name="TConfiguration">The type of tenant configuration loaded from the
/// <c>Tenants:&lt;tenantId&gt;</c> section. Must have a parameterless constructor.</typeparam>
/// <example>
/// <code language="csharp">
/// public sealed class TenantSettings
/// {
///     public string DisplayName { get; set; } = "";
/// }
///
/// var store = new ConfigurationTenantStore&lt;TenantSettings&gt;(configuration, "Tenants");
/// var settings = await store.GetConfigurationAsync("contoso");
/// </code>
/// </example>
public sealed class ConfigurationTenantStore<TConfiguration> : ITenantStore<TConfiguration>
    where TConfiguration : class, new() {
    private readonly IConfiguration _configuration;
    private readonly string _tenantsSection;

    /// <summary>
    /// Initializes a new instance of the <see cref="ConfigurationTenantStore{TConfiguration}"/> class.
    /// </summary>
    /// <param name="configuration">The configuration root.</param>
    /// <param name="tenantsSection">The configuration section containing tenant definitions. Defaults to "Tenants".</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="configuration"/> or <paramref name="tenantsSection"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var store = new ConfigurationTenantStore&lt;TenantSettings&gt;(configuration, "Tenants");
    /// </code>
    /// </example>
    public ConfigurationTenantStore(
        IConfiguration configuration,
        string tenantsSection = "Tenants") {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _tenantsSection = tenantsSection ?? throw new ArgumentNullException(nameof(tenantsSection));
    }

    /// <inheritdoc/>
    public Task<TConfiguration?> GetConfigurationAsync(string tenantId) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        var section = _configuration.GetSection($"{_tenantsSection}:{tenantId}");

        if (!section.Exists()) {
            return Task.FromResult<TConfiguration?>(null);
        }

        var config = new TConfiguration();
        section.Bind(config);

        return Task.FromResult<TConfiguration?>(config);
    }

    /// <inheritdoc/>
    public Task<bool> ExistsAsync(string tenantId) {
        if (string.IsNullOrWhiteSpace(tenantId)) {
            throw new ArgumentException("Tenant ID cannot be null or whitespace.", nameof(tenantId));
        }

        var section = _configuration.GetSection($"{_tenantsSection}:{tenantId}");
        return Task.FromResult(section.Exists());
    }

    /// <summary>
    /// Gets all tenant IDs configured in the configuration source.
    /// </summary>
    /// <returns>A collection of tenant IDs.</returns>
    /// <example>
    /// <code language="csharp">
    /// foreach (var tenantId in store.GetAllTenantIds())
    /// {
    ///     Console.WriteLine(tenantId);
    /// }
    /// </code>
    /// </example>
    public IEnumerable<string> GetAllTenantIds() {
        var tenantsSection = _configuration.GetSection(_tenantsSection);
        return tenantsSection.GetChildren().Select(c => c.Key);
    }
}