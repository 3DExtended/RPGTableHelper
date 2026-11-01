using System.Text.Json;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Authorization.Policy;
using RPGTableHelper.Shared.Auth;

namespace RPGTableHelper.WebApi.Services.Auth
{
    /// <summary>
    /// Authorization policies for API keys. Keys only reach the external player API
    /// (<see cref="ExternalApiPolicy"/> plus one <see cref="RequireScopeAttribute"/> per action) and the event
    /// stream (<see cref="EventsStreamPolicy"/>); every other endpoint uses the JWT-only default policy.
    /// </summary>
    public static class ApiKeyAuthorization
    {
        /// <summary>Authenticated via API key only. Put on every external controller.</summary>
        public const string ExternalApiPolicy = "ExternalApi";

        /// <summary>JWT, or an API key that holds the <see cref="ApiKeyScopes.Events"/> scope.</summary>
        public const string EventsStreamPolicy = "EventsStream";

        private const string ScopePolicyPrefix = "scope:";

        public static string ScopePolicy(string scope) => ScopePolicyPrefix + scope;

        public static void AddApiKeyPolicies(this AuthorizationOptions options)
        {
            options.AddPolicy(
                ExternalApiPolicy,
                policy => policy.AddAuthenticationSchemes(ApiKeyClaimTypes.AuthenticationScheme).RequireAuthenticatedUser()
            );

            foreach (var scope in ApiKeyScopes.All)
            {
                options.AddPolicy(
                    ScopePolicy(scope),
                    policy =>
                        policy
                            .AddAuthenticationSchemes(ApiKeyClaimTypes.AuthenticationScheme)
                            .RequireAuthenticatedUser()
                            .AddRequirements(new ApiKeyScopeRequirement(scope, allowOtherSchemes: false))
                );
            }

            options.AddPolicy(
                EventsStreamPolicy,
                policy =>
                    policy
                        .AddAuthenticationSchemes(
                            JwtBearerDefaults.AuthenticationScheme,
                            ApiKeyClaimTypes.AuthenticationScheme
                        )
                        .RequireAuthenticatedUser()
                        .AddRequirements(new ApiKeyScopeRequirement(ApiKeyScopes.Events, allowOtherSchemes: true))
            );
        }

        /// <summary>True if the request was authenticated with an API key (as opposed to a JWT).</summary>
        public static bool IsApiKeyRequest(this System.Security.Claims.ClaimsPrincipal user) =>
            user.Identities.Any(i => i.IsAuthenticated && i.AuthenticationType == ApiKeyClaimTypes.AuthenticationScheme);

        /// <summary>The scopes of the API key that authenticated this request; empty for JWT requests.</summary>
        public static IReadOnlyList<string> GetApiKeyScopes(this System.Security.Claims.ClaimsPrincipal user) =>
            user.Identities
                .Where(i => i.IsAuthenticated && i.AuthenticationType == ApiKeyClaimTypes.AuthenticationScheme)
                .SelectMany(i => i.FindAll(ApiKeyClaimTypes.Scope))
                .Select(c => c.Value)
                .Distinct()
                .ToList();
    }

    /// <summary>Requires the API key that authenticated the request to hold <see cref="Scope"/>.</summary>
    public sealed class ApiKeyScopeRequirement : IAuthorizationRequirement
    {
        public ApiKeyScopeRequirement(string scope, bool allowOtherSchemes)
        {
            Scope = scope;
            AllowOtherSchemes = allowOtherSchemes;
        }

        public string Scope { get; }

        /// <summary>When true, requests authenticated without an API key (JWT) pass without a scope check.</summary>
        public bool AllowOtherSchemes { get; }
    }

    public sealed class ApiKeyScopeRequirementHandler : AuthorizationHandler<ApiKeyScopeRequirement>
    {
        protected override Task HandleRequirementAsync(
            AuthorizationHandlerContext context,
            ApiKeyScopeRequirement requirement
        )
        {
            if (!context.User.IsApiKeyRequest())
            {
                if (requirement.AllowOtherSchemes && context.User.Identity?.IsAuthenticated == true)
                {
                    context.Succeed(requirement);
                }

                return Task.CompletedTask;
            }

            if (context.User.GetApiKeyScopes().Contains(requirement.Scope))
            {
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }
    }

    /// <summary>
    /// Requires the calling API key to hold <paramref name="scope"/> (see <see cref="ApiKeyScopes"/>).
    /// A key without it gets 403 with an <c>insufficient_scope</c> body naming the missing scope.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
    public sealed class RequireScopeAttribute : AuthorizeAttribute
    {
        public RequireScopeAttribute(string scope)
            : base(ApiKeyAuthorization.ScopePolicy(scope))
        {
            Scope = scope;
        }

        public string Scope { get; }
    }

    /// <summary>
    /// Turns a forbidden API key request into a 403 JSON body that names the missing scope, so client
    /// developers can tell a missing permission apart from a wrong key (401).
    /// </summary>
    public sealed class InsufficientScopeResultHandler : IAuthorizationMiddlewareResultHandler
    {
        private readonly AuthorizationMiddlewareResultHandler _defaultHandler = new();

        public async Task HandleAsync(
            RequestDelegate next,
            HttpContext context,
            AuthorizationPolicy policy,
            PolicyAuthorizationResult authorizeResult
        )
        {
            if (authorizeResult.Forbidden && context.User.IsApiKeyRequest())
            {
                var grantedScopes = context.User.GetApiKeyScopes();
                var missingScopes = policy
                    .Requirements.OfType<ApiKeyScopeRequirement>()
                    .Select(r => r.Scope)
                    .Where(scope => !grantedScopes.Contains(scope))
                    .Distinct()
                    .ToList();

                if (missingScopes.Count > 0)
                {
                    context.Response.StatusCode = StatusCodes.Status403Forbidden;
                    context.Response.ContentType = "application/json";
                    await context
                        .Response.WriteAsync(
                            JsonSerializer.Serialize(
                                new
                                {
                                    error = "insufficient_scope",
                                    requiredScopes = missingScopes,
                                    message =
                                        $"This API key lacks the scope(s) {string.Join(", ", missingScopes)}. "
                                        + "Create a key with these permissions in the Questkeeper app.",
                                }
                            )
                        )
                        .ConfigureAwait(false);
                    return;
                }
            }

            await _defaultHandler.HandleAsync(next, context, policy, authorizeResult).ConfigureAwait(false);
        }
    }
}
