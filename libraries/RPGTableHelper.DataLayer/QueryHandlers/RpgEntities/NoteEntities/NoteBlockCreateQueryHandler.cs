using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.Campagnes;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities
{
    public class NoteBlockCreateQueryHandler
        : EntityBaseCreateQueryHandlerBase<
            NoteBlockCreateQuery,
            NoteBlockModelBase,
            NoteBlockModelBase.NoteBlockModelBaseIdentifier,
            Guid,
            RpgDbContext,
            NoteBlockEntityBase
        >
    {
        private readonly IDbContextFactory<RpgDbContext> _contextFactory;

        public NoteBlockCreateQueryHandler(
            IMapper mapper,
            IDbContextFactory<RpgDbContext> contextFactory,
            ISystemClock systemClock
        )
            : base(mapper, contextFactory, systemClock)
        {
            _contextFactory = contextFactory;
        }

        /// <summary>
        /// A new block goes to the end of its document: after the last arranged block if the document's blocks were
        /// arranged, else (no <c>SortIndex</c>) by its creation date. Whatever position the caller sent is ignored.
        /// The document counts as modified.
        /// </summary>
        protected override async Task<Option<NoteBlockModelBase>> PrepareModelAsync(
            NoteBlockModelBase model,
            RpgDbContext context,
            CancellationToken cancellationToken
        )
        {
            var prepared = await base.PrepareModelAsync(model, context, cancellationToken).ConfigureAwait(false);
            if (prepared.IsNone)
            {
                return prepared;
            }

            var documentId = model.NoteDocumentId.Value;
            var lastIndex = await context
                .NoteBlocks.Where(b => b.NoteDocumentId == documentId)
                .MaxAsync(b => b.SortIndex, cancellationToken)
                .ConfigureAwait(false);
            prepared.Get().SortIndex = lastIndex.HasValue ? lastIndex.Value + 1 : null;

            await NoteDocumentTouch.MarkModifiedAsync(context, new[] { documentId }, cancellationToken).ConfigureAwait(false);
            return prepared;
        }

        /// <summary>
        /// The model-to-entity mapping deliberately ignores <c>PermittedUsers</c> (managed manually, see
        /// <see cref="NoteBlockUpdateQueryHandler"/>), so persist any permitted users requested on creation
        /// here - required for sse-07's create-time <c>granted</c> notify to reflect reality.
        /// </summary>
        protected override async Task AfterCreationAsync(
            NoteBlockCreateQuery query,
            NoteBlockModelBase.NoteBlockModelBaseIdentifier id,
            CancellationToken cancellationToken
        )
        {
            if (query.ModelToCreate.PermittedUsers.Count == 0)
            {
                return;
            }

            using var context = await _contextFactory
                .CreateDbContextAsync(cancellationToken)
                .ConfigureAwait(false);

            await context
                .PermittedUsersToNotesBlocks.AddRangeAsync(
                    query.ModelToCreate.PermittedUsers.Select(pu => new PermittedUsersToNotesBlockEntity
                    {
                        NotesBlockId = id.Value,
                        PermittedUserId = pu.Value,
                    }),
                    cancellationToken
                )
                .ConfigureAwait(false);

            await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        }
    }
}
