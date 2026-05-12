namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Provides configuration and metadata for tenants.
/// </summary>
/// <typeparam name="TConfiguration">The type of tenant-specific configuration.</typeparam>
/// <example>
/// <code language="csharp">
/// ITenantStore&lt;TenantSettings&gt; store = sp.GetRequiredService&lt;ITenantStore&lt;TenantSettings&gt;&gt;();
/// if (await store.ExistsAsync("contoso"))
/// {
///     TenantSettings? settings = await store.GetConfigurationAsync("contoso");
/// }
/// </code>
/// </example>
public interface ITenantStore<TConfiguration> where TConfiguration : class {
    /// <summary>
    /// Gets the configuration for the specified tenant.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <returns>The tenant configuration if found; otherwise, null.</returns>
    /// <example>
    /// <code language="csharp">
    /// TenantSettings? config = await store.GetConfigurationAsync("contoso");
    /// </code>
    /// </example>
    Task<TConfiguration?> GetConfigurationAsync(string tenantId);

    /// <summary>
    /// Checks if the specified tenant exists.
    /// </summary>
    /// <param name="tenantId">The tenant identifier.</param>
    /// <returns>True if the tenant exists; otherwise, false.</returns>
    /// <example>
    /// <code language="csharp">
    /// bool exists = await store.ExistsAsync("contoso");
    /// </code>
    /// </example>
    Task<bool> ExistsAsync(string tenantId);

    /// <summary>
    /// Gets all tenant IDs from the store.
    /// </summary>
    /// <returns>A collection of tenant IDs.</returns>
    /// <example>
    /// <code language="csharp">
    /// foreach (string tenantId in store.GetAllTenantIds())
    /// {
    ///     Console.WriteLine(tenantId);
    /// }
    /// </code>
    /// </example>
    IEnumerable<string> GetAllTenantIds();
}