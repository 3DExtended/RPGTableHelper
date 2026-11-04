using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.WebApi.Services.Images;

/// <summary>An uploaded image: its metadata and the link it is served at, relative to the server.</summary>
public sealed class StoredImage
{
    public ImageMetaData.ImageMetaDataIdentifier MetaDataId { get; init; } = default!;

    public string PublicUrl { get; init; } = default!;
}

/// <summary>Checks and stores an image uploaded by a user, for the app and the player API alike.</summary>
public interface IImageUploadService
{
    /// <summary>Why the file cannot be stored, or null if it can.</summary>
    Task<string?> ValidateAsync(IFormFile image, CancellationToken cancellationToken);

    /// <summary>Stores a file <see cref="ValidateAsync"/> accepted, or returns null if that fails.</summary>
    Task<StoredImage?> StoreAsync(
        Campagne.CampagneIdentifier campagneId,
        User.UserIdentifier creatorId,
        IFormFile image,
        CancellationToken cancellationToken
    );
}
