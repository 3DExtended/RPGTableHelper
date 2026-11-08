using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities;

/// <summary>
/// Moves the documents into the folder <see cref="GroupName"/> in one save. Who may do this is the caller's check.
/// None if one of the documents does not exist (any more); then nothing changed.
/// </summary>
public class NoteDocumentsSetGroupQuery : IQuery<Unit, NoteDocumentsSetGroupQuery>
{
    public IReadOnlyList<NoteDocument.NoteDocumentIdentifier> DocumentIds { get; set; } =
        Array.Empty<NoteDocument.NoteDocumentIdentifier>();

    public string GroupName { get; set; } = default!;
}
