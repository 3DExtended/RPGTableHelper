using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

internal static class NoteBlockOrder
{
    /// <summary>
    /// The blocks of the document (tracked, not deleted) in the order the app shows them: by <c>SortIndex</c>,
    /// blocks without one first, then by creation date.
    /// </summary>
    public static async Task<List<NoteBlockEntityBase>> LoadInDocumentOrderAsync(
        RpgDbContext context,
        Guid documentId,
        CancellationToken cancellationToken
    )
    {
        var blocks = await context
            .NoteBlocks.Where(b => b.NoteDocumentId == documentId)
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        return blocks.OrderBy(b => b.SortIndex ?? -1).ThenBy(b => b.CreationDate).ThenBy(b => b.Id).ToList();
    }

    /// <summary>Gives the blocks the positions 0, 1, 2, ... in list order.</summary>
    public static void Number(IReadOnlyList<NoteBlockEntityBase> blocks)
    {
        for (var index = 0; index < blocks.Count; index++)
        {
            blocks[index].SortIndex = index;
        }
    }
}
