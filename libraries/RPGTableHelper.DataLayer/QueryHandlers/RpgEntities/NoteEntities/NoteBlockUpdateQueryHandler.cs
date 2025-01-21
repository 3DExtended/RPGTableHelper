using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
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
    public class NoteBlockUpdateQueryHandler : IQueryHandler<NoteBlockUpdateQuery, Unit>
    {
        public NoteBlockUpdateQueryHandler(IMapper mapper, IDbContextFactory<RpgDbContext> contextFactory)
        {
            _mapper = mapper;
            _contextFactory = contextFactory;
        }

        private readonly IDbContextFactory<RpgDbContext> _contextFactory;
        private readonly IMapper _mapper;

        public IQueryHandler<NoteBlockUpdateQuery, Unit> Successor { get; set; } = default!;

        public async Task<Option<Unit>> RunQueryAsync(NoteBlockUpdateQuery query, CancellationToken cancellationToken)
        {
            using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
            {
                var entity = _mapper.Map<NoteBlockEntityBase>(query.UpdatedModel);

                var existingEntity = await context
                    .Set<NoteBlockEntityBase>()
                    .FirstOrDefaultAsync(e => e.Id!.Equals(query.UpdatedModel.Id.Value), cancellationToken)
                    .ConfigureAwait(false);

                if (existingEntity == null)
                {
                    return Option.None;
                }

                _mapper.Map(entity, existingEntity);

                // update permitted users manually
                var permittedUsers = await context
                    .PermittedUsersToNotesBlocks.Where(e => e.NotesBlockId == existingEntity.Id)
                    .ToListAsync(cancellationToken)
                    .ConfigureAwait(false);

                var permittedUsersToRemove = permittedUsers
                    .Where(pu => !query.UpdatedModel.PermittedUsers.Any(p => p.Value == pu.PermittedUserId))
                    .ToList();

                var permittedUsersToAdd = query
                    .UpdatedModel.PermittedUsers.Where(pu => !permittedUsers.Any(p => p.PermittedUserId == pu.Value))
                    .Select(pu => new PermittedUsersToNotesBlockEntity
                    {
                        NotesBlockId = existingEntity.Id,
                        PermittedUserId = pu.Value,
                    })
                    .ToList();

                if (permittedUsersToRemove.Any())
                {
                    context.PermittedUsersToNotesBlocks.RemoveRange(permittedUsersToRemove);
                }

                if (permittedUsersToAdd.Any())
                {
                    await context
                        .PermittedUsersToNotesBlocks.AddRangeAsync(permittedUsersToAdd, cancellationToken)
                        .ConfigureAwait(false);
                }

                await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
            }

            return Unit.Value;
        }
    }
}
