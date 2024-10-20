using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes
{
    public class CampagneNewJoinCodeQueryHandler : IQueryHandler<CampagneNewJoinCodeQuery, string>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public CampagneNewJoinCodeQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<CampagneNewJoinCodeQuery, string> Successor { get; set; } = default!;

        public async Task<Option<string>> RunQueryAsync(
            CampagneNewJoinCodeQuery query,
            CancellationToken cancellationToken
        )
        {
            using (
                var context = await _contextFactory
                    .CreateDbContextAsync(cancellationToken)
                    .ConfigureAwait(false)
            )
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

                    if (foundCampagneWithJoinCode == false)
                    {
                        return joinCodeToTry;
                    }
                    numberOfTriedCodes++;

                    if (numberOfTriedCodes >= 10)
                        break;
                }

                return Option.None;
            }
        }
    }
}
