using System.Collections.Generic;
using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.Shared.Auth;

namespace RPGTableHelper.WebApi.Services.Auth
{
    public class ApiKeyAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private const string ApiKeyHeaderName = "X-Api-Key";
        private readonly IQueryProcessor _queryProcessor;

        public ApiKeyAuthenticationHandler(
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            IQueryProcessor queryProcessor)
            : base(options, logger, encoder)
        {
            _queryProcessor = queryProcessor;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.TryGetValue(ApiKeyHeaderName, out var apiKeyHeaderValues))
            {
                return AuthenticateResult.NoResult();
            }

            var providedApiKey = apiKeyHeaderValues.FirstOrDefault();

            if (apiKeyHeaderValues.Count == 0 || string.IsNullOrWhiteSpace(providedApiKey))
            {
                return AuthenticateResult.NoResult();
            }

            var userOption = await new VerifyApiKeyQuery { PlainApiKey = providedApiKey }
                .RunAsync(_queryProcessor, Context.RequestAborted);

            if (userOption.IsNone)
            {
                return AuthenticateResult.Fail("Invalid API Key provided.");
            }

            var verifiedKey = userOption.Get();
            var user = verifiedKey.User;

            string idValue = user.Id.Value.ToString();
            string nameValue = user.Username ?? idValue;

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, nameValue),
                new Claim("identityproviderid", idValue),
                new Claim(ClaimTypes.Name, nameValue),
                new Claim(ApiKeyClaimTypes.ApiKeyId, verifiedKey.ApiKeyId.ToString()),
                new Claim(ApiKeyClaimTypes.ApiKeyPrefix, verifiedKey.Prefix),
            };

            claims.AddRange(verifiedKey.Scopes.Select(scope => new Claim(ApiKeyClaimTypes.Scope, scope)));

            var identity = new ClaimsIdentity(claims, Scheme.Name);
            var principal = new ClaimsPrincipal(identity);
            var ticket = new AuthenticationTicket(principal, Scheme.Name);

            return AuthenticateResult.Success(ticket);
        }
    }
}
