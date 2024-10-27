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
    public class CampagneByJoinCodeQueryHandler : IQueryHandler<CampagneByJoinCodeQuery, Campagne>
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly IMapper _mapper;

        public CampagneByJoinCodeQueryHandler(IDbContextFactory<RpgDbContext> contextFactory, IMapper mapper)
        {
            _contextFactory = contextFactory;
            _mapper = mapper;
        }

        public IQueryHandler<CampagneByJoinCodeQuery, Campagne> Successor { get; set; } = default!;

        public async Task<Option<Campagne>> RunQueryAsync(
            CampagneByJoinCodeQuery query,
            CancellationToken cancellationToken
        )
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var campagneEntity = await context
                    .Set<CampagneEntity>()
                    .Where((e) => e.JoinCode == query.JoinCode)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (campagneEntity == null)
                {
                    return Option.None;
                }

                return _mapper.Map<Campagne>(campagneEntity);
            }
        }
    }
}
