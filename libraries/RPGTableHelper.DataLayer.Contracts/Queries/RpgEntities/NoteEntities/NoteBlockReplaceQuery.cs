using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;

/// <summary>
/// Replaces a block by <see cref="Replacement"/>, e.g. a text block by an image block with the same text. The new
/// block gets a new id and takes the old one's document, author, position and who may read it; the old block is
/// deleted. Only the content of <see cref="Replacement"/> counts. Who may do this is the caller's check. Returns
/// the new block's id; None if the block does not exist (any more), then nothing changed.
/// </summary>
public class NoteBlockReplaceQuery
    : IQuery<NoteBlockModelBase.NoteBlockModelBaseIdentifier, NoteBlockReplaceQuery>
{
    public NoteBlockModelBase.NoteBlockModelBaseIdentifier BlockId { get; set; } = default!;

    public NoteBlockModelBase Replacement { get; set; } = default!;
}
