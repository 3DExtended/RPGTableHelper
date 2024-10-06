using System.Security.Claims;
using System.Security.Cryptography;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using RPGTableHelper.WebApi.Options;

namespace RPGTableHelper.WebApi.Services
{
    public class AppleClientSecretGenerator
    {
        private readonly IMemoryCache _cache;
        private readonly AppleAuthOptions _context;
        private readonly CryptoProviderFactory _cryptoProviderFactory =
            new() { CacheSignatureProviders = false };

        public AppleClientSecretGenerator(IMemoryCache cache, AppleAuthOptions context)
        {
            _cache = cache;
            _context = context;
        }

        public async Task<string> GenerateAsync()
        {
            string key = CreateCacheKey(_context);

            var clientSecret = await _cache.GetOrCreateAsync(
                key,
                async (entry) =>
                {
                    try
                    {
                        (string clientSecret, DateTimeOffset expiresAt) =
                            await GenerateNewSecretAsync(_context);
                        entry.AbsoluteExpiration = expiresAt;
                        return clientSecret;
                    }
                    catch (Exception)
                    {
                        throw;
                    }
                }
            );

            return clientSecret!;
        }

        private static ECDsa CreateAlgorithm(ReadOnlyMemory<char> pem)
        {
            var algorithm = ECDsa.Create();

            try
            {
                algorithm.ImportFromPem(pem.Span);
                return algorithm;
            }
            catch (Exception)
            {
                algorithm?.Dispose();
                throw;
            }
        }

        private static string CreateCacheKey(AppleAuthOptions options)
        {
            var segments = new[]
            {
                nameof(AppleClientSecretGenerator),
                "ClientSecret",
                options.TeamId,
                options.ClientId,
                options.KeyId,
            };

            return string.Join('+', segments);
        }

        private SigningCredentials CreateSigningCredentials(string keyId, ECDsa algorithm)
        {
            var key = new ECDsaSecurityKey(algorithm) { KeyId = keyId };

            // Use a custom CryptoProviderFactory so that keys are not cached and then disposed of, see below:
            // https://github.com/AzureAD/azure-activedirectory-identitymodel-extensions-for-dotnet/issues/1302
            return new SigningCredentials(key, SecurityAlgorithms.EcdsaSha256)
            {
                CryptoProviderFactory = _cryptoProviderFactory,
            };
        }

        private Task<(string ClientSecret, DateTime ExpiresAt)> GenerateNewSecretAsync(
            AppleAuthOptions context
        )
        {
            var expiresAt = DateTime.UtcNow.AddHours(context.ClientSecretExpiresAfterHours);
            var subject = new Claim("sub", context.ClientId);

            var tokenDescriptor = new SecurityTokenDescriptor()
            {
                Audience = "https://appleid.apple.com",
                Expires = expiresAt,
                Issuer = context.TeamId,
                Subject = new ClaimsIdentity(new[] { subject }),
            };

            var pem = context.Key.AsMemory();
            string clientSecret;

            using (var algorithm = CreateAlgorithm(pem))
            {
                tokenDescriptor.SigningCredentials = CreateSigningCredentials(
                    context.KeyId!,
                    algorithm
                );

                clientSecret = new JsonWebTokenHandler().CreateToken(tokenDescriptor);
            }

            return Task.FromResult((clientSecret, expiresAt));
        }
    }
}
