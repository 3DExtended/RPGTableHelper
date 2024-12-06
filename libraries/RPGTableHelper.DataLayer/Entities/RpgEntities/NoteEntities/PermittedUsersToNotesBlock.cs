using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

public class PermittedUsersToNotesBlock
{
    [Key]
    public int Id { get; set; } = default!;

    public DateTime CreationDate { get; set; }

    [ForeignKey(nameof(PermittedUser))]
    public Guid PermittedUserId { get; set; } = Guid.Empty;

    public virtual UserEntity PermittedUser { get; set; } = default!;

    [ForeignKey(nameof(NotesBlock))]
    public Guid NotesBlockId { get; set; } = Guid.Empty;

    public virtual NoteBlockEntityBase NotesBlock { get; set; } = default!;
}
