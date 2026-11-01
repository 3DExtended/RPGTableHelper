using System.Reflection;
using Microsoft.OpenApi;
using RPGTableHelper.WebApi.Controllers.External;
using RPGTableHelper.WebApi.Services.Auth;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace RPGTableHelper.WebApi.Swagger
{
    /// <summary>
    /// Documents how each player API operation is authenticated: with the <c>X-Api-Key</c> header instead of the
    /// app's JWT, which scope the key needs, and the answers every key can get (401, 403, 429).
    /// </summary>
    public class ExternalApiOperationFilter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            if (context.ApiDescription.GroupName != ExternalApiRoutes.SwaggerGroupName)
            {
                return;
            }

            var scopes = context
                .MethodInfo.GetCustomAttributes<RequireScopeAttribute>(inherit: true)
                .Concat(context.MethodInfo.DeclaringType?.GetCustomAttributes<RequireScopeAttribute>(inherit: true) ?? [])
                .Select(attribute => attribute.Scope)
                .Distinct()
                .ToList();

            operation.Security = new List<OpenApiSecurityRequirement>
            {
                new() { [new OpenApiSecuritySchemeReference("ApiKey", context.Document, externalResource: null)] = [] },
            };

            var scopeText = scopes.Count == 0
                ? "Needs a valid API key, no particular scope."
                : $"Required scope: `{string.Join("`, `", scopes)}`.";
            operation.Description = string.IsNullOrWhiteSpace(operation.Description)
                ? scopeText
                : operation.Description + "\n\n" + scopeText;

            operation.Responses ??= new OpenApiResponses();
            SetDescription(operation, "401", "No X-Api-Key header, or the key is unknown, revoked or expired.");
            SetDescription(operation, "429", "Too many requests with this key; wait the seconds in the Retry-After header.");
            if (scopes.Count > 0)
            {
                var missingScope = $"The key lacks `{string.Join("`, `", scopes)}` (error insufficient_scope).";
                if (operation.Responses.TryGetValue("403", out var forbidden)
                    && forbidden is OpenApiResponse endpointSpecific
                    && !string.IsNullOrWhiteSpace(endpointSpecific.Description)
                    && endpointSpecific.Description != "Forbidden")
                {
                    endpointSpecific.Description = $"{endpointSpecific.Description} (error forbidden). Or: {missingScope}";
                }
                else
                {
                    SetDescription(operation, "403", missingScope);
                }
            }
        }

        private static void SetDescription(OpenApiOperation operation, string statusCode, string description)
        {
            if (operation.Responses!.TryGetValue(statusCode, out var response) && response is OpenApiResponse existing)
            {
                existing.Description = description;
            }
            else
            {
                operation.Responses[statusCode] = new OpenApiResponse { Description = description };
            }
        }
    }
}
