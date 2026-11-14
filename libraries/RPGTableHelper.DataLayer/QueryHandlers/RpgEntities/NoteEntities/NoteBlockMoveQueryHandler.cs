using Microsoft.EntityFrameworkCore;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

public class NoteBlockMoveQueryHandler : IQueryHandler<NoteBlockMoveQuery, Unit>
{
    private readonly IDbContextFactory<RpgDbContext> _contextFactory;

    public NoteBlockMoveQueryHandler(IDbContextFactory<RpgDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public IQueryHandler<NoteBlockMoveQuery, Unit> Successor { get; set; } = default!;

    public async Task<Option<Unit>> RunQueryAsync(NoteBlockMoveQuery query, CancellationToken cancellationToken)
    {
        using var context = await _contextFactory.CreateDbContextAsync(cancellationToken).ConfigureAwait(false);

        var block = await context
            .NoteBlocks.FirstOrDefaultAsync(b => b.Id == query.BlockId.Value, cancellationToken)
            .ConfigureAwait(false);
        if (block == null)
        {
            return Option.None;
        }

        var blocks = await NoteBlockOrder
            .LoadInDocumentOrderAsync(context, block.NoteDocumentId, cancellationToken)
            .ConfigureAwait(false);
        blocks.RemoveAll(b => b.Id == block.Id);

        if (query.BeforeBlockId.IsNone)
        {
            blocks.Add(block);
        }
        else
        {
            var anchorIndex = blocks.FindIndex(b => b.Id == query.BeforeBlockId.Get().Value);
            if (anchorIndex < 0)
            {
                return Option.None;
            }

            blocks.Insert(anchorIndex, block);
        }

        NoteBlockOrder.Number(blocks);
        await NoteDocumentTouch
            .MarkModifiedAsync(context, new[] { block.NoteDocumentId }, cancellationToken)
            .ConfigureAwait(false);
        await context.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
        return Unit.Value;
    }
}
