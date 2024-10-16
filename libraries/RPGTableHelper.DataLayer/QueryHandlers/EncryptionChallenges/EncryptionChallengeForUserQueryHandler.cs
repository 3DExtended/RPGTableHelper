using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Encryptions;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;

namespace RPGTableHelper.DataLayer.QueryHandlers.EncryptionChallenges
{
    public class EncryptionChallengeForUserQueryHandler
        : IQueryHandler<EncryptionChallengeForUserQuery, EncryptionChallenge>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public EncryptionChallengeForUserQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<
            EncryptionChallengeForUserQuery,
            EncryptionChallenge
        > Successor { get; set; } = default!;

        public async Task<Option<EncryptionChallenge>> RunQueryAsync(
            EncryptionChallengeForUserQuery query,
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
                    .Set<EncryptionChallengeEntity>()
                    .Where((e) => e.UserId != null && e.User!.Username == query.Username)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entity == null)
                    return Option.None;

                return _mapper.Map<EncryptionChallenge>(entity);
            }
        }
    }
}
