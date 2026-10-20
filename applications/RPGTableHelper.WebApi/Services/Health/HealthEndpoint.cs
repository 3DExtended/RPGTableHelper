namespace RPGTableHelper.WebApi.Services.Health;

/// <summary>
/// GET and HEAD /health for the uptime check in uhs-cockpit, asked every minute: 200 "Healthy" when the API can read
/// its database, 503 "Unhealthy" when it cannot. Plain text with the status word only (never a check's description
/// or exception), no caching, and no login: it is anonymous on its own, so no default or fallback policy reaches it.
/// </summary>
public static class HealthEndpoint
{
    public const string Path = "/health";

    public static IServiceCollection AddApiHealthChecks(this IServiceCollection services)
    {
        services.AddHealthChecks().AddCheck<DatabaseHealthCheck>(DatabaseHealthCheck.Name);
        return services;
    }

    public static IEndpointConventionBuilder MapApiHealthEndpoint(this IEndpointRouteBuilder endpoints)
    {
        return endpoints
            .MapHealthChecks(Path)
            .WithMetadata(new HttpMethodMetadata(new[] { HttpMethods.Get, HttpMethods.Head }))
            .AllowAnonymous();
    }
}
