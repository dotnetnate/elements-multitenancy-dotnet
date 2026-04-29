using Microsoft.Extensions.Options;

namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Provides tenant-specific options resolved from the current tenant context.
/// Backed by <see cref="IOptionsMonitor{TOptions}"/> with the tenant ID as the named options key.
/// </summary>
/// <typeparam name="TOptions">The type of options.</typeparam>
/// <example>
/// <code language="csharp">
/// public class TenantAwareReportService
/// {
///     private readonly TenantOptions&lt;ReportSettings&gt; _options;
///     public TenantAwareReportService(TenantOptions&lt;ReportSettings&gt; options) =&gt; _options = options;
///
///     public string Render() =&gt; $"Logo: {_options.Value.LogoUrl}";
/// }
/// </code>
/// </example>
public sealed class TenantOptions<TOptions> where TOptions : class {
    private readonly IOptionsMonitor<TOptions> _monitor;
    private readonly ITenantContextAccessor _tenantContextAccessor;

    /// <summary>
    /// Initializes a new instance of the <see cref="TenantOptions{TOptions}"/> class.
    /// </summary>
    /// <param name="monitor">The options monitor.</param>
    /// <param name="tenantContextAccessor">The tenant context accessor.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="monitor"/> or <paramref name="tenantContextAccessor"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var options = new TenantOptions&lt;ReportSettings&gt;(monitor, accessor);
    /// </code>
    /// </example>
    public TenantOptions(IOptionsMonitor<TOptions> monitor, ITenantContextAccessor tenantContextAccessor) {
        _monitor = monitor ?? throw new ArgumentNullException(nameof(monitor));
        _tenantContextAccessor = tenantContextAccessor ?? throw new ArgumentNullException(nameof(tenantContextAccessor));
    }

    /// <summary>
    /// Gets the options for the current tenant.
    /// </summary>
    /// <exception cref="InvalidOperationException">Thrown when the tenant context is not available or unresolved.</exception>
    /// <example>
    /// <code language="csharp">
    /// ReportSettings settings = tenantOptions.Value;
    /// </code>
    /// </example>
    public TOptions Value {
        get {
            var context = _tenantContextAccessor.TenantContext;

            if (context == null || !context.IsResolved) {
                throw new InvalidOperationException(
                    "Cannot get options: tenant context is not available or unresolved.");
            }

            return _monitor.Get(context.TenantId);
        }
    }
}