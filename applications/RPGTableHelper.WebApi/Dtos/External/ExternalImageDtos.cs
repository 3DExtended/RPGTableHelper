using System.ComponentModel.DataAnnotations;

namespace RPGTableHelper.WebApi.Dtos.External;

/// <summary>An image for the campaign, sent as <c>multipart/form-data</c>.</summary>
public class ExternalImageUploadRequestDto
{
    /// <summary>The image: PNG or JPEG, at most 10 MB.</summary>
    [Required]
    public IFormFile Image { get; set; } = default!;
}

/// <summary>An uploaded image.</summary>
public class ExternalImageDto
{
    /// <summary>
    /// The link relative to the server, e.g. <c>/public/getimage/...</c>. Put this into a <c>singleImage</c> stat's
    /// <c>imageUrl</c>: every version of the app shows it.
    /// </summary>
    public string Path { get; set; } = default!;

    /// <summary>The full link, to load the image yourself.</summary>
    public string ImageUrl { get; set; } = default!;
}
