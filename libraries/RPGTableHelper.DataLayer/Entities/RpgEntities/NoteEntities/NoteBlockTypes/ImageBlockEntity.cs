using System.ComponentModel.DataAnnotations.Schema;
using RPGTableHelper.DataLayer.Entities.Images;

namespace RPGTableHelper.DataLayer.Entities.RpgEntities.NoteEntities;

public class ImageBlockEntity : NoteBlockEntityBase
{
    [ForeignKey(nameof(ImageMetaData))]
    public Guid ImageMetaDataId { get; set; } = Guid.Empty;
    public virtual ImageMetaDataEntity? ImageMetaData { get; set; }

    public string PublicImageUrl { get; set; } = default!;
}
