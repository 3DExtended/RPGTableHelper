using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities
{
    public class NoteDocumentQueryHandler
        : SingleModelQueryHandlerBase<
            NoteDocumentQuery,
            NoteDocument,
            NoteDocument.NoteDocumentIdentifier,
            Guid,
            RpgDbContext,
            NoteDocumentEntity
        >
    {
        public NoteDocumentQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
            : base(mapper, contextFactory) { }

        protected override IQueryable<NoteDocumentEntity> AddIncludes(IQueryable<NoteDocumentEntity> queryable)
        {
            return queryable.Include(x => x.NoteBlocks).ThenInclude(n => n.PermittedUsers);
        }
    }
}
