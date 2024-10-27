using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes
{
    public class CampagneNewJoinCodeQueryHandler : IQueryHandler<CampagneNewJoinCodeQuery, string>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public CampagneNewJoinCodeQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
        {
            _contextFactory = contextFactory;
        }

        public IQueryHandler<CampagneNewJoinCodeQuery, string> Successor { get; set; } = default!;

        public async Task<Option<string>> RunQueryAsync(
            CampagneNewJoinCodeQuery query,
            CancellationToken cancellationToken
        )
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                int numberOfTriedCodes = 0;
                while (true)
                {
                    var joinCodeToTry = ApiKeyGenerator.GenerateJoinCode();

                    var foundCampagneWithJoinCode = await context
                        .Set<CampagneEntity>()
                        .Where((e) => e.JoinCode == joinCodeToTry)
                        .AsNoTracking()
                        .AnyAsync(cancellationToken)
                        .ConfigureAwait(false);

                    if (!foundCampagneWithJoinCode)
                    {
                        return joinCodeToTry;
                    }

                    numberOfTriedCodes++;

                    if (numberOfTriedCodes >= 10)
                    {
                        break;
                    }
                }

                return Option.None;
            }
        }
    }
}
