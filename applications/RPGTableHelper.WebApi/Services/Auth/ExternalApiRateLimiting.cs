using System.Globalization;
using System.Text.Json;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Options;
using RPGTableHelper.Shared.Auth;

namespace RPGTableHelper.WebApi.Services.Auth
{
    /// <summary>
    /// Per-key rate limits for the external player API. Over the limit a key gets 429 with a
    /// <c>Retry-After</c> header and a <c>rate_limited</c> JSON body.
    /// </summary>
    public static class ExternalApiRateLimiting
    {
        public static IServiceCollection AddExternalApiRateLimiting(
            this IServiceCollection services,
            IConfiguration configuration
        )
        {
            services.Configure<ExternalApiRateLimitOptions>(
                configuration.GetSection(ExternalApiRateLimitOptions.SectionName)
            );
            services.AddRateLimiter(_ => { });
            services
                .AddOptions<RateLimiterOptions>()
                .Configure<IOptions<ExternalApiRateLimitOptions>>(
                    (options, limits) => Configure(options, limits.Value)
                );
            return services;
        }

        private static void Configure(RateLimiterOptions options, ExternalApiRateLimitOptions limits)
        {
            var allRequests = PartitionedRateLimiter.Create<HttpContext, string>(context =>
            {
                var apiKeyId = GetApiKeyId(context);
                return apiKeyId == null
                    ? RateLimitPartition.GetNoLimiter(string.Empty)
                    : RateLimitPartition.GetFixedWindowLimiter(apiKeyId, _ => PerMinute(limits.RequestsPerMinute));
            });

            var writes = PartitionedRateLimiter.Create<HttpContext, string>(context =>
            {
                var apiKeyId = GetApiKeyId(context);
                return apiKeyId == null || IsRead(context.Request.Method)
                    ? RateLimitPartition.GetNoLimiter(string.Empty)
                    : RateLimitPartition.GetFixedWindowLimiter(apiKeyId, _ => PerMinute(limits.WritesPerMinute));
            });

            options.GlobalLimiter = PartitionedRateLimiter.CreateChained(allRequests, writes);
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.OnRejected = OnRejectedAsync;
        }

        private static async ValueTask OnRejectedAsync(OnRejectedContext context, CancellationToken cancellationToken)
        {
            var retryAfter = context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var wait)
                ? wait
                : TimeSpan.FromMinutes(1);
            var retryAfterSeconds = Math.Max(1, (int)Math.Ceiling(retryAfter.TotalSeconds));

            var httpContext = context.HttpContext;
            httpContext
                .RequestServices.GetRequiredService<ILoggerFactory>()
                .CreateLogger(typeof(ExternalApiRateLimiting).FullName!)
                .LogInformation(
                    "API key {ApiKeyPrefix} hit the rate limit on {Method} {Path}",
                    httpContext.User.FindFirst(ApiKeyClaimTypes.ApiKeyPrefix)?.Value,
                    SanitizeForLog(httpContext.Request.Method),
                    SanitizeForLog(httpContext.Request.Path.ToString())
                );

            httpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
            httpContext.Response.Headers.RetryAfter = retryAfterSeconds.ToString(CultureInfo.InvariantCulture);
            httpContext.Response.ContentType = "application/json";
            await httpContext
                .Response.WriteAsync(
                    JsonSerializer.Serialize(
                        new
                        {
                            error = "rate_limited",
                            message = $"Too many requests with this API key. Try again in {retryAfterSeconds} s.",
                            retryAfterSeconds,
                        }
                    ),
                    cancellationToken
                )
                .ConfigureAwait(false);
        }

        private static FixedWindowRateLimiterOptions PerMinute(int permits) =>
            new()
            {
                PermitLimit = permits,
                Window = TimeSpan.FromMinutes(1),
                QueueLimit = 0,
                AutoReplenishment = true,
            };

        private static string? GetApiKeyId(HttpContext context) =>
            context.User.IsApiKeyRequest() ? context.User.FindFirst(ApiKeyClaimTypes.ApiKeyId)?.Value : null;

        private static bool IsRead(string method) =>
            HttpMethods.IsGet(method) || HttpMethods.IsHead(method) || HttpMethods.IsOptions(method);

        /// <summary>Strips CR and LF from a request value so it cannot forge extra log lines.</summary>
        private static string SanitizeForLog(string value) =>
            value.Replace("\r", string.Empty).Replace("\n", string.Empty);
    }

    /// <summary>How many requests one API key may make; requests with a JWT are not limited.</summary>
    public sealed class ExternalApiRateLimitOptions
    {
        public const string SectionName = "ExternalApi:RateLimit";

        /// <summary>All requests of one key per minute.</summary>
        public int RequestsPerMinute { get; set; } = 120;

        /// <summary>Requests of one key per minute that change something (anything but GET, HEAD, OPTIONS).</summary>
        public int WritesPerMinute { get; set; } = 30;
    }
}
