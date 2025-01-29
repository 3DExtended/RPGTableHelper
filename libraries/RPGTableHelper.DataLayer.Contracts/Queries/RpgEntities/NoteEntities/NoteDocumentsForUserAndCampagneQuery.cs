using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;

namespace RPGTableHelper.DataLayer.Contracts.Queries.RpgEntities.NoteDocuments
{
    public class NoteDocumentsForUserAndCampagneQuery
        : IQuery<IReadOnlyList<NoteDocument>, NoteDocumentsForUserAndCampagneQuery>
    {
        public Campagne.CampagneIdentifier CampagneId { get; set; } = default!;
        public User.UserIdentifier UserId { get; set; } = default!;
    }
}
