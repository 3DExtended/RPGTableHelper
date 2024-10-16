using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UserExistsByInternalIdQueryHandler
        : IQueryHandler<UserExistsByInternalIdQuery, User.UserIdentifier>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public UserExistsByInternalIdQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
        {
            _contextFactory = contextFactory;
        }

        public IQueryHandler<
            UserExistsByInternalIdQuery,
            User.UserIdentifier
        > Successor { get; set; } = default!;

        public async Task<Option<User.UserIdentifier>> RunQueryAsync(
            UserExistsByInternalIdQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
            {
                var entity = await context
                    .Set<UserEntity>()
                    .Where((e) => e.SignInProviderId == query.InternalId)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                {
                    return Option.None;
                }

                return User.UserIdentifier.From(entity.Id);
            }
        }
    }
}
