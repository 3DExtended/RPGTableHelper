using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.CampagneJoinRequests;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.CampagneJoinRequests
{
    public class CampagneJoinRequestQueryHandler
        : SingleModelQueryHandlerBase<
            CampagneJoinRequestQuery,
            CampagneJoinRequest,
            CampagneJoinRequest.CampagneJoinRequestIdentifier,
            Guid,
            RpgDbContext,
            CampagneJoinRequestEntity
        >
    {
        public CampagneJoinRequestQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }
    }
}
