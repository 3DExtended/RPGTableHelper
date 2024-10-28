using System.Net;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.Apple;
using RPGTableHelper.Shared.Options;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;

namespace RPGTableHelper.DataLayer.QueryHandlers.Apple;

public class VerifyAppleOAuthTokenQueryHandler
    : IQueryHandler<VerifyAppleOAuthTokenQuery, AppleTokenResponse>
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly AppleAuthOptions _appleAuthOptions;
    private readonly IAppleClientSecretGenerator _appleClientSecretGenerator;

    public VerifyAppleOAuthTokenQueryHandler(
        IHttpClientFactory httpClientFactory,
        AppleAuthOptions appleAuthOptions,
        IAppleClientSecretGenerator appleClientSecretGenerator
    )
    {
        _httpClientFactory = httpClientFactory;
        _appleAuthOptions = appleAuthOptions;
        _appleClientSecretGenerator = appleClientSecretGenerator;
    }

    public IQueryHandler<VerifyAppleOAuthTokenQuery, AppleTokenResponse> Successor { get; set; } =
        default!;

    public async Task<Option<AppleTokenResponse>> RunQueryAsync(
        VerifyAppleOAuthTokenQuery query,
        CancellationToken cancellationToken
    )
    {
        var clientSecret = await _appleClientSecretGenerator.GenerateAsync().ConfigureAwait(false);

        using (var httpClient = _httpClientFactory.CreateClient())
        {
            using (
                var request = new HttpRequestMessage(
                    new HttpMethod("POST"),
                    "https://appleid.apple.com/auth/token"
                )
            )
            {
                var contentList = new List<string>
                {
                    "client_id=" + _appleAuthOptions.ClientId,
                    "client_secret=" + clientSecret,
                    "code=" + WebUtility.UrlEncode(query.AuthorizationCode),
                    "grant_type=authorization_code",
                };

                request.Content = new StringContent(string.Join("&", contentList));
                request.Content.Headers.ContentType = MediaTypeHeaderValue.Parse(
                    "application/x-www-form-urlencoded"
                );

                var response = await httpClient.SendAsync(request);
                var appleTokenString = await response
                    .Content.ReadAsStringAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (appleTokenString.Contains("error_description") || appleTokenString.Contains("invalid_client"))
                {
                    return Option.None;
                }

                var appleTokenResponse = JsonConvert.DeserializeObject<AppleTokenResponse>(
                    appleTokenString
                )!;

                return appleTokenResponse;
            }
        }
    }
}
