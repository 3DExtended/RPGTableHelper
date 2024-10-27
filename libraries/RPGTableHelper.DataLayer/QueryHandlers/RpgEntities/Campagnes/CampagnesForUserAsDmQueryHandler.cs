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

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes
{
    public class CampagnesForUserAsDmQueryHandler
        : IQueryHandler<CampagnesForUserAsDmQuery, IReadOnlyList<Campagne>>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public CampagnesForUserAsDmQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<
            CampagnesForUserAsDmQuery,
            IReadOnlyList<Campagne>
        > Successor { get; set; } = default!;

        public async Task<Option<IReadOnlyList<Campagne>>> RunQueryAsync(
            CampagnesForUserAsDmQuery query,
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
                    .Set<CampagneEntity>()
                    .Where((e) => e.DmUserId == query.UserId.Value)
                    .AsNoTracking()
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entities == null)
                {
                    return Option.None;
                }

                return entities.Select(_mapper.Map<Campagne>).ToList();
            }
        }
    }
}
