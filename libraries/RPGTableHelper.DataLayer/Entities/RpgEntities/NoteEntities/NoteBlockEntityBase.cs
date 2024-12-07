using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

public abstract class NoteBlockEntityBase : EntityBase<Guid>
{
    [ForeignKey(nameof(NoteDocument))]
    public Guid NoteDocumentId { get; set; } = Guid.Empty;
    public bool IsDeleted { get; set; } = default!;

    public virtual NoteDocumentEntity? NoteDocument { get; set; }

    [ForeignKey(nameof(CreatingUser))]
    public Guid CreatingUserId { get; set; } = Guid.Empty;
    public virtual UserEntity? CreatingUser { get; set; }

    public NotesBlockVisibility Visibility { get; set; }

    public ICollection<PermittedUsersToNotesBlockEntity>? PermittedUsers { get; set; } =
        new List<PermittedUsersToNotesBlockEntity>();
}
