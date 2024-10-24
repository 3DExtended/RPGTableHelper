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
    public class PlayerCharactersForUserAsPlayerQueryHandler
        : IQueryHandler<PlayerCharactersForUserAsPlayerQuery, IReadOnlyList<PlayerCharacter>>
    {
        private readonly IMapper _mapper;
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public PlayerCharactersForUserAsPlayerQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        public IQueryHandler<
            PlayerCharactersForUserAsPlayerQuery,
            IReadOnlyList<PlayerCharacter>
        > Successor { get; set; } = default!;

        public async Task<Option<IReadOnlyList<PlayerCharacter>>> RunQueryAsync(
            PlayerCharactersForUserAsPlayerQuery query,
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
                    .Set<PlayerCharacterEntity>()
                    .Where((e) => e.PlayerUserId == query.UserId.Value)
                    .AsNoTracking()
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);

                if (entities == null)
                {
                    return Option.None;
                }

                return entities.Select(_mapper.Map<PlayerCharacter>).ToList();
            }
        }
    }
}
