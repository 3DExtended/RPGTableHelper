using AutoMapper;
using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            CampagneJoinRequestCreateQuery,
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            RpgDbContext,
            CampagneJoinRequestEntity
        >
    {
        public CampagneJoinRequestCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock) { }
    }
}
