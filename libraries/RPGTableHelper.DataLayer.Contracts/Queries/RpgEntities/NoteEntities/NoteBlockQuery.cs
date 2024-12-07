using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments
{
    public class NoteBlockQuery
        : SingleModelQuery<
            NoteBlockModelBase,
            NoteBlockModelBase.NoteBlockModelBaseIdentifier,
            Guid,
            NoteBlockQuery
        > { }
}
