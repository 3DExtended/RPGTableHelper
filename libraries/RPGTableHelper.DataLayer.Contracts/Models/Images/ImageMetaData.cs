using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;

namespace RPGTableHelper.DataLayer.Contracts.Models.Images;

public class ImageMetaData : NodeModelBase<ImageMetaData.ImageMetaDataIdentifier, Guid>
{
    public Campagne.CampagneIdentifier CreatedForCampagneId { get; set; } = default!;
    public bool LocallyStored { get; set; } = default!;
    public string ApiKey { get; set; } = default!;

    public User.UserIdentifier CreatorId { get; set; } = default!;
    public ImageType ImageType { get; set; } = default!;

    public record ImageMetaDataIdentifier : Identifier<Guid, ImageMetaDataIdentifier> { }
}
