using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities
{
    public class NoteDocument : NodeModelBase<NoteDocument.NoteDocumentIdentifier, Guid>
    {
        public string GroupName { get; set; } = default!;
        public bool IsDeleted { get; set; } = false;

        public User.UserIdentifier CreatingUserId { get; set; } = default!;
        public string Title { get; set; } = default!;
        public Campagne.CampagneIdentifier CreatedForCampagneId { get; set; } = default!;

        public IList<NoteBlockModelBase> NoteBlocks { get; set; } = new List<NoteBlockModelBase>();

        public record NoteDocumentIdentifier : Identifier<Guid, NoteDocumentIdentifier> { }
    }
}
