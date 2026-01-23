using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.ApiKeys;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.ApiKeys
{
    public class RevokeApiKeyQueryHandler : IQueryHandler<RevokeApiKeyQuery, bool>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _clock;

        public RevokeApiKeyQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock)
        {
            _contextFactory = contextFactory;
            _clock = systemClock;
        }

        public IQueryHandler<RevokeApiKeyQuery, bool> Successor { get; set; } = default!;

        public async Task<Option<bool>> RunQueryAsync(RevokeApiKeyQuery query, CancellationToken cancellationToken)
        {
            using var context = await _contextFactory.CreateDbContextAsync(cancellationToken);

            var entity = await context.ApiKeys
                .FirstOrDefaultAsync(k => k.Id == query.ApiKeyId && k.UserId == query.UserId.Value, cancellationToken);

            if (entity == null)
            {
                return Option.None;
            }

            if (entity.RevokedAt.HasValue)
            {
                return Option.From(true); // Already revoked
            }

            entity.RevokedAt = _clock.Now;
            await context.SaveChangesAsync(cancellationToken);
            return Option.From(true);
        }
    }
}
