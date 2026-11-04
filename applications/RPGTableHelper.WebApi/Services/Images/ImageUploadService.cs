using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Contracts.Queries.Images;
using RPGTableHelper.Shared.Services;

namespace RPGTableHelper.WebApi.Services.Images;

public class ImageUploadService : IImageUploadService
{
    private const long MaxFileSize = 10 * 1024 * 1024; // 10 MB

    private static readonly string[] PermittedExtensions = { ".jpg", ".jpeg", ".png" };
    private static readonly string[] PermittedMimeTypes = { "image/jpeg", "image/jpg", "image/png" };
    private static readonly byte[] PngSignature = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };
    private static readonly byte[] JpegSignature = { 0xFF, 0xD8, 0xFF };

    private readonly IQueryProcessor _queryProcessor;

    public ImageUploadService(IQueryProcessor queryProcessor)
    {
        _queryProcessor = queryProcessor;
    }

    public async Task<string?> ValidateAsync(IFormFile image, CancellationToken cancellationToken)
    {
        if (image.Length > MaxFileSize)
        {
            return $"File size exceeds the maximum limit of {MaxFileSize / (1024 * 1024)} MB.";
        }

        if (image.Length == 0)
        {
            return "File size is 0 MB.";
        }

        var extension = Path.GetExtension(image.FileName).ToLowerInvariant();
        if (string.IsNullOrEmpty(extension) || !PermittedExtensions.Contains(extension))
        {
            return "Invalid file type.";
        }

        if (!PermittedMimeTypes.Contains(image.ContentType))
        {
            return "Invalid MIME type.";
        }

        return await DetectImageTypeAsync(image, cancellationToken).ConfigureAwait(false) == null
            ? "The file is not a PNG or JPEG image."
            : null;
    }

    public async Task<StoredImage?> StoreAsync(
        Campagne.CampagneIdentifier campagneId,
        User.UserIdentifier creatorId,
        IFormFile image,
        CancellationToken cancellationToken
    )
    {
        var imageType = await DetectImageTypeAsync(image, cancellationToken).ConfigureAwait(false);
        if (imageType == null)
        {
            return null;
        }

        var apikey = ApiKeyGenerator.GenerateKey(32);
        var newMetadata = new ImageMetaData
        {
            CreatedForCampagneId = campagneId,
            CreatorId = creatorId,
            ApiKey = apikey,
            ImageType = imageType.Value,
            LocallyStored = true,
        };

        var metadata = await new ImageMetaDataCreateQuery { ModelToCreate = newMetadata }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (metadata.IsNone)
        {
            return null;
        }

        newMetadata.Id = metadata.Get();

        await using var imageStream = image.OpenReadStream();

        var saveResult = await new ImageSaveQuery { Stream = imageStream, MetaData = newMetadata }
            .RunAsync(_queryProcessor, cancellationToken)
            .ConfigureAwait(false);

        if (saveResult.IsNone)
        {
            return null;
        }

        return new StoredImage
        {
            MetaDataId = newMetadata.Id,
            PublicUrl = $"/public/getimage/{newMetadata.Id.Value}/{apikey}?metadataid={newMetadata.Id.Value}",
        };
    }

    /// <summary>What the file really is, going by its first bytes and not by what the client says.</summary>
    private static async Task<ImageType?> DetectImageTypeAsync(IFormFile image, CancellationToken cancellationToken)
    {
        var header = new byte[PngSignature.Length];
        await using var stream = image.OpenReadStream();
        var read = await stream.ReadAtLeastAsync(header, header.Length, throwOnEndOfStream: false, cancellationToken).ConfigureAwait(false);
        var start = header.AsSpan(0, read);

        if (start.StartsWith(PngSignature))
        {
            return ImageType.PNG;
        }

        return start.StartsWith(JpegSignature) ? ImageType.JPEG : null;
    }
}
