using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UserLoginQueryHandler : IQueryHandler<UserLoginQuery, User.UserIdentifier>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public UserLoginQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
        {
            _contextFactory = contextFactory;
        }

        public IQueryHandler<UserLoginQuery, User.UserIdentifier> Successor { get; set; } =
            default!;

        public async Task<Option<User.UserIdentifier>> RunQueryAsync(
            UserLoginQuery query,
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
                    .Set<UserCredentialEntity>()
                    .Where(
                        (e) =>
                            e.HashedPassword == query.HashedPassword
                            && e.User != null
                            && query.Username == e.User!.Username
                    )
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                {
                    return Option.None;
                }

                return User.UserIdentifier.From(entity.UserId);
            }
        }
    }
}
