using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.Campagnes;

public class CampagneUpdateQueryHandler
    : UpdateCommandHandlerBase<
        CampagneUpdateQuery,
        Campagne,
        Campagne.CampagneIdentifier,
        Guid,
        RpgDbContext,
        CampagneEntity
    >
{
    public CampagneUpdateQueryHandler(
        IMapper mapper,
        IDbContextFactory<RpgDbContext> contextFactory
    )
        : base(mapper, contextFactory) { }
}
