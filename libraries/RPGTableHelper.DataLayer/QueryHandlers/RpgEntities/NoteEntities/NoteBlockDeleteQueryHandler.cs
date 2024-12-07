using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteBlockDeleteQueryHandler : IQueryHandler<NoteBlockDeleteQuery, Unit>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public NoteBlockDeleteQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public IQueryHandler<NoteBlockDeleteQuery, Unit> Successor { get; set; } = default!;

    public async Task<Option<Unit>> RunQueryAsync(NoteBlockDeleteQuery query, CancellationToken cancellationToken)
    {
        using (var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false))
        {
            var entityToDelete = await context.NoteBlocks.FirstOrDefaultAsync(
                x => x.Id == query.Id.Value,
                cancellationToken
            );

            if (entityToDelete == null || entityToDelete.IsDeleted)
            {
                return Option.None;
            }

            entityToDelete.IsDeleted = true;
            await context.SaveChangesAsync(cancellationToken);

            return Option.From(Unit.Value);
        }
    }
}
