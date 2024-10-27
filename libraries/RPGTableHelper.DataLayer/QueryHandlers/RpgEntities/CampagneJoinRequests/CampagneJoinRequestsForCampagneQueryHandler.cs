using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestsForCampagneQueryHandler
        : IQueryHandler<
            CampagneJoinRequestsForCampagneQuery,
            IReadOnlyList<(CampagneJoinRequest request, PlayerCharacter playerCharacter, string username)>
        >
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly IMapper _mapper;

        public CampagneJoinRequestsForCampagneQueryHandler(
            IDbContextFactory<RpgDbContext> contextFactory,
            IMapper mapper
        )
        {
            _contextFactory = contextFactory;
            _mapper = mapper;
        }

        public IQueryHandler<
            CampagneJoinRequestsForCampagneQuery,
            IReadOnlyList<(CampagneJoinRequest request, PlayerCharacter playerCharacter, string username)>
        > Successor { get; set; } = default!;

        public async Task<
            Option<IReadOnlyList<(CampagneJoinRequest request, PlayerCharacter playerCharacter, string username)>>
        > RunQueryAsync(CampagneJoinRequestsForCampagneQuery query, CancellationToken cancellationToken)
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var requestsForCampagne = await context
                    .Set<CampagneJoinRequestEntity>()
                    .Where((e) => e.CampagneId == query.CampagneId.Value)
                    .Include(e => e.Campagne)
                    .Include(e => e.Player)
                    .Include(e => e.User)
                    .AsNoTracking()
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (requestsForCampagne == null)
                {
                    return Option.None;
                }

                return requestsForCampagne
                    .Select(c =>
                        (
                            _mapper.Map<CampagneJoinRequest>(c!),
                            _mapper.Map<PlayerCharacter>(c.Player!),
                            c.User!.Username
                        )
                    )
                    .ToList();
            }
        }
    }
}
