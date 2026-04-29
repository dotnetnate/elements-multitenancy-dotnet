using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.Security.Authorization;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Action filter that validates the authenticated user has access to the tenant
/// identified by a route parameter. Global admin users bypass this check.
/// </summary>
/// <remarks>
/// Apply this attribute to controllers or actions that accept a tenant identifier
/// in the route. The filter compares the user's tenant claim against the route value.
/// Users with the configured admin role (default: "global-admin") are allowed access
/// to any tenant.
/// </remarks>
/// <example>
/// <code language="csharp">
/// [ApiController]
/// [Route("api/tenants/{tenantId}/orders")]
/// [ValidateTenantAccess(RouteParameterName = "tenantId", AdminRole = "global-admin")]
/// public class OrdersController : ControllerBase
/// {
///     [HttpGet]
///     public IActionResult List(string tenantId) =&gt; Ok();
/// }
/// </code>
/// </example>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false)]
public sealed class ValidateTenantAccessAttribute : ActionFilterAttribute {
    /// <summary>
    /// Gets or sets the route parameter name that contains the tenant identifier.
    /// Defaults to "tenantId".
    /// </summary>
    public string RouteParameterName { get; set; } = "tenantId";

    /// <summary>
    /// Gets or sets the role name that bypasses tenant validation (cross-tenant access).
    /// Defaults to "global-admin".
    /// </summary>
    public string AdminRole { get; set; } = "global-admin";

    /// <inheritdoc />
    public override void OnActionExecuting(ActionExecutingContext context) {
        var userContext = context.HttpContext.RequestServices.GetRequiredService<IUserContext>();

        if (!userContext.IsAuthenticated) {
            context.Result = new UnauthorizedResult();
            return;
        }

        // Admin users can access any tenant
        if (userContext.HasRole(AdminRole)) {
            base.OnActionExecuting(context);
            return;
        }

        // Extract tenant ID from route
        if (!context.RouteData.Values.TryGetValue(RouteParameterName, out var routeTenantValue)
            || routeTenantValue is not string routeTenantId
            || string.IsNullOrWhiteSpace(routeTenantId)) {
            context.Result = new BadRequestObjectResult(new ProblemDetails {
                Title = "Missing tenant identifier",
                Detail = $"Route parameter '{RouteParameterName}' is required.",
                Status = StatusCodes.Status400BadRequest
            });
            return;
        }

        // Compare user's tenant with route tenant
        if (!string.Equals(userContext.TenantId, routeTenantId, StringComparison.OrdinalIgnoreCase)) {
            context.Result = new ObjectResult(new ProblemDetails {
                Title = "Forbidden",
                Detail = "You do not have access to this tenant.",
                Status = StatusCodes.Status403Forbidden
            }) {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return;
        }

        base.OnActionExecuting(context);
    }
}