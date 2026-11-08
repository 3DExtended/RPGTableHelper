using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;

/// <summary>
/// Puts the blocks into <see cref="DocumentId"/> in exactly this order (<c>SortIndex</c> 0, 1, 2, ...), moving any
/// block that sits in another document. A block keeps its id, author, content and who may read it. Who may do this
/// (own blocks, same campaign, every block of the document listed) is the caller's check. None if a block or the
/// document does not exist (any more); then nothing changed.
/// </summary>
public class NoteBlocksArrangeQuery : IQuery<Unit, NoteBlocksArrangeQuery>
{
    public NoteDocument.NoteDocumentIdentifier DocumentId { get; set; } = default!;

    public IReadOnlyList<NoteBlockModelBase.NoteBlockModelBaseIdentifier> OrderedBlockIds { get; set; } =
        Array.Empty<NoteBlockModelBase.NoteBlockModelBaseIdentifier>();
}
