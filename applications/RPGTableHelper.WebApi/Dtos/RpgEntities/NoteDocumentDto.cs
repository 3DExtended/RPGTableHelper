using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using static RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities.NoteDocument;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

public class NoteDocumentDto
{
    public DateTimeOffset CreationDate { get; set; }

    public DateTimeOffset LastModifiedAt { get; set; }

    public NoteDocument.NoteDocumentIdentifier Id { get; set; }
    public string GroupName { get; set; } = default!;

    public User.UserIdentifier CreatingUserId { get; set; } = default!;
    public string Title { get; set; } = default!;
    public Campagne.CampagneIdentifier CreatedForCampagneId { get; set; } = default!;

    public IList<ImageBlock> ImageBlocks { get; set; } = new List<ImageBlock>();
    public IList<TextBlock> TextBlocks { get; set; } = new List<TextBlock>();
}
