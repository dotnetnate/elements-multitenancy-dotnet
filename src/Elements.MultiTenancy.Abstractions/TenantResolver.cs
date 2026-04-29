using Microsoft.Extensions.Logging;

namespace MyOrg.Elements.MultiTenancy;

/// <summary>
/// Default implementation of <see cref="ITenantResolver{TContext}"/> that uses registered strategies.
/// </summary>
/// <typeparam name="TContext">The type of context used for resolution.</typeparam>
/// <example>
/// <code language="csharp">
/// var strategies = new ITenantResolutionStrategy&lt;HttpContext&gt;[]
/// {
///     new HeaderTenantResolutionStrategy(options),
///     new HostTenantResolutionStrategy(options),
/// };
/// var resolver = new TenantResolver&lt;HttpContext&gt;(strategies, new DefaultTenantIdParser(), logger);
/// ITenantContext ctx = await resolver.ResolveAsync(httpContext);
/// </code>
/// </example>
public sealed class TenantResolver<TContext> : ITenantResolver<TContext> {
    private readonly List<ITenantResolutionStrategy<TContext>> _strategies;
    private readonly ITenantIdParser _tenantIdParser;
    private readonly ILogger<TenantResolver<TContext>>? _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="TenantResolver{TContext}"/> class.
    /// </summary>
    /// <param name="strategies">The resolution strategies to use.</param>
    /// <param name="tenantIdParser">The tenant ID parser.</param>
    /// <param name="logger">The logger.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="tenantIdParser"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var resolver = new TenantResolver&lt;HttpContext&gt;(strategies, new DefaultTenantIdParser());
    /// </code>
    /// </example>
    public TenantResolver(
        IEnumerable<ITenantResolutionStrategy<TContext>> strategies,
        ITenantIdParser tenantIdParser,
        ILogger<TenantResolver<TContext>>? logger = null) {
        _strategies = strategies.OrderBy(s => s.Priority).ToList();
        _tenantIdParser = tenantIdParser ?? throw new ArgumentNullException(nameof(tenantIdParser));
        _logger = logger;
    }

    /// <inheritdoc/>
    public async Task<ITenantContext> ResolveAsync(TContext context) {
        _logger?.LogDebug("Attempting tenant resolution with {StrategyCount} strategies", _strategies.Count);
        foreach (var strategy in _strategies) {
            _logger?.LogDebug("Trying resolution strategy {StrategyType} with priority {Priority}", strategy.GetType().Name, strategy.Priority);
            var rawTenantId = await strategy.ResolveAsync(context).ConfigureAwait(false);
            if (!string.IsNullOrWhiteSpace(rawTenantId)) {
                var normalizedTenantId = _tenantIdParser.Parse(rawTenantId);
                if (!string.IsNullOrWhiteSpace(normalizedTenantId)) {
                    return new TenantContext(normalizedTenantId);
                }
            }
        }

        return TenantContext.Unresolved;
    }
}