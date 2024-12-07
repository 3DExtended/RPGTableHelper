using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities
{
    public class NoteDocumentUpdateQueryHandler
        : UpdateCommandHandlerBase<
            NoteDocumentUpdateQuery,
            NoteDocument,
            NoteDocument.NoteDocumentIdentifier,
            Guid,
            RpgDbContext,
            NoteDocumentEntity
        >
    {
        public NoteDocumentUpdateQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }
    }
}
