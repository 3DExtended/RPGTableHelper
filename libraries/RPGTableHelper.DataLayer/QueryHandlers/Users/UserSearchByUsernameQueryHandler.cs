using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.Users
{
    public class UserSearchByUsernameQueryHandler
        : IQueryHandler<UserSearchByUsernameQuery, IReadOnlyList<User>>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly IMapper _mapper;

        public UserSearchByUsernameQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            IMapper mapper
        )
        {
            _contextFactory = contextFactory;
            _mapper = mapper;
        }

        public IQueryHandler<
            UserSearchByUsernameQuery,
            IReadOnlyList<User>
        > Successor { get; set; } = default!;

        public async Task<Option<IReadOnlyList<User>>> RunQueryAsync(
            UserSearchByUsernameQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
            {
                var entities = await context
                    .Set<UserEntity>()
                    .Where((e) => e.Username.ToLower().Contains(query.UsernamePart.ToLower()))
                    .Take(query.Limit)
                    .AsNoTracking()
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entities == null)
                {
                    return Option.None;
                }

                return Option.From(
                    (IReadOnlyList<User>)entities.Select(_mapper.Map<User>).ToList()
                );
            }
        }
    }
}
