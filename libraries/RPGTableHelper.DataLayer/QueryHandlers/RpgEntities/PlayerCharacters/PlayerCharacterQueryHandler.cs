using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters
{
    public class PlayerCharacterQueryHandler
        : SingleModelQueryHandlerBase<
            PlayerCharacterQuery,
            PlayerCharacter,
            PlayerCharacter.PlayerCharacterIdentifier,
            Guid,
            RpgDbContext,
            PlayerCharacterEntity
        >
    {
        public PlayerCharacterQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory
        )
            : base(mapper, contextFactory) { }
    }
}
