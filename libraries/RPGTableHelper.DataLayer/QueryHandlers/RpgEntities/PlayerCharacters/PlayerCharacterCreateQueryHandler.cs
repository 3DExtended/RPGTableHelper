using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.PlayerCharacters;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.PlayerCharacters
{
    public class PlayerCharacterCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            PlayerCharacterCreateQuery,
            PlayerCharacter,
            PlayerCharacter.PlayerCharacterIdentifier,
            Guid,
            RpgDbContext,
            PlayerCharacterEntity
        >
    {
        public PlayerCharacterCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
