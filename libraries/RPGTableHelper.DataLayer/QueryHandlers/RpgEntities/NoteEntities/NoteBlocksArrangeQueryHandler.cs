using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteBlocksArrangeQueryHandler : IQueryHandler<NoteBlocksArrangeQuery, Unit>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public NoteBlocksArrangeQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public IQueryHandler<NoteBlocksArrangeQuery, Unit> Successor { get; set; } = default!;

    public async Task<Option<Unit>> RunQueryAsync(NoteBlocksArrangeQuery query, CancellationToken cancellationToken)
    {
        var targetId = query.DocumentId.Value;
        var blockIds = query.OrderedBlockIds.Select(id => id.Value).ToList();

        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        var targetExists = await context
            .CampagneDocuments.AnyAsync(d => d.Id == targetId, cancellationToken)
            .ConfigureAwait(false);
        if (!targetExists)
        {
            return Option.None;
        }

        var blocks = await context
            .NoteBlocks.Where(b => blockIds.Contains(b.Id))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        if (blocks.Count != blockIds.Distinct().Count())
        {
            return Option.None;
        }

        var touchedDocuments = blocks.Select(b => b.NoteDocumentId).Append(targetId).ToList();
        var byId = blocks.ToDictionary(b => b.Id);
        for (var index = 0; index < blockIds.Count; index++)
        {
            var block = byId[blockIds[index]];
            block.NoteDocumentId = targetId;
            block.SortIndex = index;
        }

        await NoteDocumentTouch.MarkModifiedAsync(context, touchedDocuments, cancellationToken).ConfigureAwait(false);
        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return Unit.Value;
    }
}
