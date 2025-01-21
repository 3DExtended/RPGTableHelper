using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities
{
    public class ImageBlock : NoteBlockModelBase
    {
        [Required]
        public ImageMetaData.ImageMetaDataIdentifier ImageMetaDataId { get; set; } = default!;

        [Required]
        public string PublicImageUrl { get; set; } = default!;

        public string? MarkdownText { get; set; } = null;
    }
}
