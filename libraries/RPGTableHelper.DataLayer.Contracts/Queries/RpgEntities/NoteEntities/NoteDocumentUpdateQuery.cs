using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteEntities
{
    public class NoteDocumentUpdateQuery
        : UpdateCommand<NoteDocument, NoteDocument.NoteDocumentIdentifier, Guid, NoteDocumentUpdateQuery> { }
}
