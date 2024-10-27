using Microsoft.Extensions.Caching.Memory;
using Newtonsoft.Json;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Apple;

namespace RPGTableHelper.DataLayer.QueryHandlers.Apple;

public class AppleAuthKeysQueryHandler : IQueryHandler<AppleAuthKeysQuery, AppleKeysResponse>
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IMemoryCache _memoryCache;

    public AppleAuthKeysQueryHandler(IHttpClientFactory httpClientFactory, IMemoryCache memoryCache)
    {
        _httpClientFactory = httpClientFactory;
        _memoryCache = memoryCache;
    }

    public IQueryHandler<AppleAuthKeysQuery, AppleKeysResponse> Successor { get; set; } = default!;

    public async Task<Option<AppleKeysResponse>> RunQueryAsync(
        AppleAuthKeysQuery query,
        CancellationToken cancellationToken
    )
    {
        const string cacheKey = nameof(AppleAuthKeysQueryHandler) + "applekeys";
        var result = await _memoryCache.GetOrCreateAsync<AppleKeysResponse>(
            cacheKey,
            async (entry) =>
            {
                entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMicroseconds(1);

                // Download apple keys from here: https://appleid.apple.com/auth/keys
                var url = "https://appleid.apple.com/auth/keys";

                using (var httpClient = _httpClientFactory.CreateClient())
                {
                    var response = await httpClient.GetAsync(url).ConfigureAwait(false);

                    if (response.IsSuccessStatusCode)
                    {
                        var content = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                        var appleKeys = JsonConvert.DeserializeObject<AppleKeysResponse>(content);

                        if (appleKeys != null)
                        {
                            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(4);
                        }

                        return appleKeys!;
                    }
                    else
                    {
                        // Handle error response here (e.g., log the status code, throw an exception, etc.)
                        throw new HttpRequestException($"Request failed with status code {response.StatusCode}");
                    }
                }
            }
        );

        return result!;
    }
}
