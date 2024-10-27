using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UserExistsByUsernameQueryHandler
        : IQueryHandler<UserExistsByUsernameQuery, User.UserIdentifier>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public UserExistsByUsernameQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
        {
            _contextFactory = contextFactory;
        }

        public IQueryHandler<
            UserExistsByUsernameQuery,
            User.UserIdentifier
        > Successor { get; set; } = default!;

        public async Task<Option<User.UserIdentifier>> RunQueryAsync(
            UserExistsByUsernameQuery query,
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
                    .Where((e) => e.Username == query.Username)
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
