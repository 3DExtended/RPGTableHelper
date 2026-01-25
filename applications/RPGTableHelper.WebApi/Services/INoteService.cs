using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.WebApi.Services
{
    public interface INoteService
    {
        Task<Option<IReadOnlyList<NoteDocument>>> GetNoteDocumentsForUserAsync(
            Guid campaignId,
            Guid userId,
            CancellationToken cancellationToken
        );

        Task<Option<NoteDocument>> GetNoteDocumentByIdAsync(
            Guid documentId,
            Guid userId,
            CancellationToken cancellationToken
        );
    }
}
