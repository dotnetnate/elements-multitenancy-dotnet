using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy.AspNet;
using MyOrg.Elements.Security.Authorization;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class ValidateTenantAccessAttributeTests
{
    [TestMethod]
    public void OnActionExecuting_When_User_Is_Not_Authenticated_Then_Returns_Unauthorized()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: false, tenantId: "tenant1"), "tenant1");
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        Assert.IsInstanceOfType<UnauthorizedResult>(context.Result);
    }

    [TestMethod]
    public void OnActionExecuting_When_User_Has_Admin_Role_Then_Allows_Access()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "tenant1", roles: ["global-admin"]), "tenant2");
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        Assert.IsNull(context.Result);
    }

    [TestMethod]
    public void OnActionExecuting_When_Route_Tenant_Is_Missing_Then_Returns_Bad_Request()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "tenant1"), routeTenantId: null);
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        var result = Assert.IsInstanceOfType<BadRequestObjectResult>(context.Result);
        var problem = Assert.IsInstanceOfType<ProblemDetails>(result.Value);
        Assert.AreEqual(StatusCodes.Status400BadRequest, problem.Status);
    }

    [TestMethod]
    public void OnActionExecuting_When_Route_Tenant_Is_Not_A_String_Then_Returns_Bad_Request()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "tenant1"), routeTenantId: 123);
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        Assert.IsInstanceOfType<BadRequestObjectResult>(context.Result);
    }

    [TestMethod]
    public void OnActionExecuting_When_Route_Tenant_Is_Whitespace_Then_Returns_Bad_Request()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "tenant1"), "   ");
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        Assert.IsInstanceOfType<BadRequestObjectResult>(context.Result);
    }

    [TestMethod]
    public void OnActionExecuting_When_User_Tenant_Does_Not_Match_Route_Then_Returns_Forbidden()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "tenant1"), "tenant2");
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        var result = Assert.IsInstanceOfType<ObjectResult>(context.Result);
        Assert.AreEqual(StatusCodes.Status403Forbidden, result.StatusCode);
        var problem = Assert.IsInstanceOfType<ProblemDetails>(result.Value);
        Assert.AreEqual(StatusCodes.Status403Forbidden, problem.Status);
    }

    [TestMethod]
    public void OnActionExecuting_When_User_Tenant_Matches_Route_Ignoring_Case_Then_Allows_Access()
    {
        var context = CreateContext(new TestUserContext(isAuthenticated: true, tenantId: "TENANT1"), "tenant1");
        var attribute = new ValidateTenantAccessAttribute();

        attribute.OnActionExecuting(context);

        Assert.IsNull(context.Result);
    }

    [TestMethod]
    public void OnActionExecuting_When_Custom_Route_And_Admin_Role_Are_Configured_Then_Uses_Custom_Values()
    {
        var context = CreateContext(
            new TestUserContext(isAuthenticated: true, tenantId: "tenant1", roles: ["super-admin"]),
            "tenant2",
            routeParameterName: "organizationId");
        var attribute = new ValidateTenantAccessAttribute
        {
            RouteParameterName = "organizationId",
            AdminRole = "super-admin"
        };

        attribute.OnActionExecuting(context);

        Assert.IsNull(context.Result);
    }

    private static ActionExecutingContext CreateContext(TestUserContext userContext, object? routeTenantId, string routeParameterName = "tenantId")
    {
        var services = new ServiceCollection()
            .AddSingleton<IUserContext>(userContext)
            .BuildServiceProvider();

        var httpContext = new DefaultHttpContext
        {
            RequestServices = services
        };
        var routeData = new RouteData();
        if (routeTenantId is not null)
        {
            routeData.Values[routeParameterName] = routeTenantId;
        }

        var actionContext = new ActionContext(httpContext, routeData, new ActionDescriptor());
        return new ActionExecutingContext(actionContext, [], new Dictionary<string, object?>(), new object());
    }

    private sealed class TestUserContext : IUserContext
    {
        private readonly HashSet<string> _roles;

        public TestUserContext(bool isAuthenticated, string tenantId, IEnumerable<string>? roles = null)
        {
            IsAuthenticated = isAuthenticated;
            TenantId = tenantId;
            _roles = new HashSet<string>(roles ?? [], StringComparer.OrdinalIgnoreCase);
        }

        public string UserId => "user1";

        public string Email => "user@example.com";

        public string Name => "Test User";

        public string TenantId { get; }

        public string TenantName => "Test Tenant";

        public IEnumerable<string> Roles => _roles;

        public bool IsAuthenticated { get; }

        public bool HasRole(string role) => _roles.Contains(role);
    }
}