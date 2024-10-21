using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.UserCredentials;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.UserCredentials
{
    public class UserCredentialConfirmEmailQueryHandler : IQueryHandler<UserCredentialConfirmEmailQuery, Unit>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly ISystemClock _systemClock;

        public UserCredentialConfirmEmailQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
        {
            _contextFactory = contextFactory;
            _systemClock = systemClock;
        }

        public IQueryHandler<UserCredentialConfirmEmailQuery, Unit> Successor { get; set; } = default!;

        public async Task<Option<Unit>> RunQueryAsync(
            UserCredentialConfirmEmailQuery query,
            CancellationToken cancellationToken
        )
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var entity = await context
                    .Set<UserCredentialEntity>()
                    .Where((e) => e.UserId == query.UserIdentifier.Value)
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                {
                    return Option.None;
                }

                entity.EmailVerified = true;
                entity.LastModifiedAt = _systemClock.Now;

                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

                return Unit.Value;
            }
        }
    }
}
