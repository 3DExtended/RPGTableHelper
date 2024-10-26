using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestDeleteQueryHandler
        : DeleteCommandHandlerBase<
            CampagneJoinRequestDeleteQuery,
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            RpgDbContext,
            CampagneJoinRequestEntity
        >
    {
        public CampagneJoinRequestDeleteQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
            : base(contextFactory) { }
    }
}
