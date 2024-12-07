using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteBlockQueryHandler
    : SingleModelQueryHandlerBase<
        NoteBlockQuery,
        NoteBlockModelBase,
        NoteBlockModelBase.NoteBlockModelBaseIdentifier,
        Guid,
        RpgDbContext,
        NoteBlockEntityBase
    >
{
    public NoteBlockQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
        : base(mapper, contextFactory) { }
}
