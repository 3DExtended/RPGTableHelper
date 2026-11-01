using System.Security.Cryptography;
using System.Text;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.ApiKeys;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.ApiKeys
{
    public class VerifyApiKeyQueryHandler : IQueryHandler<VerifyApiKeyQuery, VerifiedApiKey>
    {
        /// <summary>
        /// <see cref="Entities.ApiKeyEntity.LastUsedAt"/> is only written when older than this, so a busy key
        /// does not cause a database write per request.
        /// </summary>
        public static readonly TimeSpan LastUsedUpdateInterval = TimeSpan.FromMinutes(1);

        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public VerifyApiKeyQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<VerifyApiKeyQuery, VerifiedApiKey> Successor { get; set; } = default!;

        public async Task<Option<VerifiedApiKey>> RunQueryAsync(VerifyApiKeyQuery query, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(query.PlainApiKey))
            {
                return Option.None;
            }

            // Hash the input key
            using var sha256 = SHA256.Create();
            var hashBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(query.PlainApiKey));
            var hash = Convert.ToBase64String(hashBytes);

            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var apiKeyEntity = await context.ApiKeys
                .Include(k => k.User)
                .AsNoTracking()
                .FirstOrDefaultAsync(k => k.KeyHash == hash, cancellationToken);

            if (apiKeyEntity == null || apiKeyEntity.RevokedAt.HasValue)
            {
                return Option.None;
            }

            var now = _clock.Now;
            if (apiKeyEntity.ExpiresAt.HasValue && apiKeyEntity.ExpiresAt.Value <= now)
            {
                return Option.None;
            }

            if (!apiKeyEntity.LastUsedAt.HasValue || now - apiKeyEntity.LastUsedAt.Value >= LastUsedUpdateInterval)
            {
                await context.ApiKeys
                    .Where(k => k.Id == apiKeyEntity.Id)
                    .ExecuteUpdateAsync(setters => setters.SetProperty(k => k.LastUsedAt, now), cancellationToken);
            }

            return Option.From(new VerifiedApiKey
            {
                User = _mapper.Map<User>(apiKeyEntity.User),
                ApiKeyId = apiKeyEntity.Id,
                Prefix = apiKeyEntity.Prefix,
                Scopes = ApiKeyScopes.Parse(apiKeyEntity.Scopes),
            });
        }
    }
}
