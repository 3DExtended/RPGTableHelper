using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments
{
    public class NoteDocumentCreateQuery
        : CreateQuery<NoteDocument, NoteDocument.NoteDocumentIdentifier, Guid, NoteDocumentCreateQuery> { }
}
