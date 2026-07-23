using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
