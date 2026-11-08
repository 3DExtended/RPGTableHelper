using Microsoft.EntityFrameworkCore;
using RPGTableHelper.DataLayer.EfCore;

namespace RPGTableHelper.DataLayer.QueryHandlers.RpgEntities.NoteEntities;

/// <summary>
/// A document's <c>LastModifiedAt</c> covers its blocks: creating, changing (also only who may read it), moving or
/// deleting a block marks the document as modified, so a client can tell from the document alone whether anything
/// in it changed since it last read it.
/// </summary>
internal static class NoteDocumentTouch
{
    /// <summary>
    /// Marks the documents as modified in <paramref name="context"/>; the next <c>SaveChanges</c> stamps them with
    /// the current time (see <see cref="RpgDbContext"/>).
    /// </summary>
    public static async Task MarkModifiedAsync(
        RpgDbContext context,
        IEnumerable<Guid> documentIds,
        CancellationToken cancellationToken
    )
    {
        var ids = documentIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            return;
        }

        var documents = await context
            .CampagneDocuments.Where(d => ids.Contains(d.Id))
            .ToListAsync(cancellationToken)
            .ConfigureAwait(false);
        foreach (var document in documents)
        {
            context.Entry(document).Property(d => d.LastModifiedAt).IsModified = true;
        }
    }
}
