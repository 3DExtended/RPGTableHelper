using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters
{
    public class PlayerCharactersForCampagneQueryHandler
        : IQueryHandler<PlayerCharactersForCampagneQuery, IReadOnlyList<PlayerCharacter>>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public PlayerCharactersForCampagneQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<PlayerCharactersForCampagneQuery, IReadOnlyList<PlayerCharacter>> Successor { get; set; } =
            default!;

        public async Task<Option<IReadOnlyList<PlayerCharacter>>> RunQueryAsync(
            PlayerCharactersForCampagneQuery query,
            CancellationToken cancellationToken
        )
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var campagneEntity = await context
                    .Set<CampagneEntity>()
                    .Include(x => x.Characters)
                    .Where((e) => e.Id == query.CampagneId.Value)
                    .AsNoTracking()
                    .SingleOrDefaultAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (campagneEntity == null || campagneEntity.Characters == null)
                {
                    return Option.None;
                }

                return campagneEntity.Characters.Select(_mapper.Map<PlayerCharacter>).ToList();
            }
        }
    }
}
