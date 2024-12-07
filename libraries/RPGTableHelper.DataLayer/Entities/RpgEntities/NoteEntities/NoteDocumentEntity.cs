using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.DataLayer.Entities.Base;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

public class NoteDocumentEntity : EntityBase<Guid>
{
    public string GroupName { get; set; } = default!;

    public bool IsDeleted { get; set; } = default!;

    public string Title { get; set; } = default!;

    [ForeignKey(nameof(CreatingUser))]
    public Guid CreatingUserId { get; set; } = Guid.Empty;
    public virtual UserEntity? CreatingUser { get; set; }

    [ForeignKey(nameof(CreatedForCampagne))]
    public Guid CreatedForCampagneId { get; set; } = Guid.Empty;
    public virtual CampagneEntity? CreatedForCampagne { get; set; }

    public ICollection<NoteBlockEntityBase> NoteBlocks { get; } = new List<NoteBlockEntityBase>(); // Collection navigation containing dependents
}
