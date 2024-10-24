using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes
{
    public class CampagneCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            CampagneCreateQuery,
            Campagne,
            Campagne.CampagneIdentifier,
            Guid,
            RpgDbContext,
            CampagneEntity
        >
    {
        public CampagneCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
