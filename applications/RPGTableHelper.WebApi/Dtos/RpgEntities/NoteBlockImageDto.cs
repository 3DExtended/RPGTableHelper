using System.ComponentModel.DataAnnotations;
using RPGTableHelper.DataLayer.Contracts.Models.Images;

namespace RPGTableHelper.WebApi.Dtos.RpgEntities;

/// <summary>An uploaded or generated image to put into a note block.</summary>
public class NoteBlockImageDto
{
    [Required]
    public ImageMetaData.ImageMetaDataIdentifier ImageMetaDataId { get; set; } = default!;

    [Required]
    public string PublicImageUrl { get; set; } = default!;
}
