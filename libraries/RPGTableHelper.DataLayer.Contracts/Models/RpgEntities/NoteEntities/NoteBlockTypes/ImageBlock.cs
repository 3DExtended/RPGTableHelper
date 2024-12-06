using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities
{
    public class ImageBlock : NoteBlockModelBase
    {
        public ImageMetaData.ImageMetaDataIdentifier ImageMetaDataId { get; set; } = default!;
        public string PublicImageUrl { get; set; } = default!;
    }
}
