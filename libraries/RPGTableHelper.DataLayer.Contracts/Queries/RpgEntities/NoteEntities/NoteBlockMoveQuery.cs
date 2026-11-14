using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;

/// <summary>
/// Moves a block within its document: right before <see cref="BeforeBlockId"/>, or to the end if that is none.
/// Afterwards every block of the document has a <c>SortIndex</c> (0, 1, 2, ...) in the order the app shows.
/// Who may do this is the caller's check. None if the block does not exist (any more), or the anchor is not
/// another block of the same document; then nothing changed.
/// </summary>
public class NoteBlockMoveQuery : IQuery<Unit, NoteBlockMoveQuery>
{
    public NoteBlockModelBase.NoteBlockModelBaseIdentifier BlockId { get; set; } = default!;

    public Option<NoteBlockModelBase.NoteBlockModelBaseIdentifier> BeforeBlockId { get; set; } = Option.None;
}
