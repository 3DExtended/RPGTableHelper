using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;

namespace RPGTableHelper.WebApi.Services
{
    public class NoteService : INoteService
    {
        private readonly IQueryProcessor _queryProcessor;

        public NoteService(IQueryProcessor queryProcessor)
        {
            _queryProcessor = queryProcessor;
        }

        public async Task<Option<IReadOnlyList<NoteDocument>>> GetNoteDocumentsForUserAsync(
            Guid campaignId,
            Guid userId,
            CancellationToken cancellationToken
        )
        {
            var campId = RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.Campagne.CampagneIdentifier.From(
                campaignId
            );
            var userIdentifier = RPGTableHelper.DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId);

            var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
            {
                CampagneId = campId,
                UserIdToCheck = userIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (isUserInCampagneResult.IsNone || !isUserInCampagneResult.Get())
            {
                return null;
            }

            var noteDocuments = await new NoteDocumentsForUserAndCampagneQuery
            {
                CampagneId = campId,
                UserId = userIdentifier,
            }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            // noteDocuments is Option<List<...>>
            return noteDocuments;
        }

        public async Task<Option<NoteDocument>> GetNoteDocumentByIdAsync(
            Guid documentId,
            Guid userId,
            CancellationToken cancellationToken
        )
        {
            var noteId = NoteDocument.NoteDocumentIdentifier.From(documentId);
            var userIdentifier = RPGTableHelper.DataLayer.Contracts.Models.Auth.User.UserIdentifier.From(userId);

            var noteDocumentOption = await new NoteDocumentQuery { ModelId = noteId }
                .RunAsync(_queryProcessor, cancellationToken)
                .ConfigureAwait(false);

            if (noteDocumentOption.IsNone)
            {
                return Option.None;
            }

            var noteDocument = noteDocumentOption.Get();
            var campaignId = noteDocument.CreatedForCampagneId;

            if (!noteDocument.CreatingUserId.Equals(userIdentifier))
            {
                var isUserInCampagneResult = await new CampagneIsUserInCampagneQuery
                {
                    CampagneId = campaignId,
                    UserIdToCheck = userIdentifier,
                }
                    .RunAsync(_queryProcessor, cancellationToken)
                    .ConfigureAwait(false);

                if (isUserInCampagneResult.IsNone || !isUserInCampagneResult.Get())
                {
                    return Option.None;
                }

                if (!noteDocument.NoteBlocks.Any(b => b.PermittedUsers.Contains(userIdentifier)))
                {
                    return Option.None;
                }
            }

            return noteDocument;
        }
    }
}
