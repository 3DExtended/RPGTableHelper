using System.ComponentModel.DataAnnotations.Schema;
using Prodot.Patterns.Cqrs.EfCore;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Models.BaseModels;
using RPGTableHelper.DataLayer.Contracts.Models.Images;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities;
using RPGTableHelper.DataLayer.Entities;
using RPGTableHelper.DataLayer.Entities.Base;
using RPGTableHelper.DataLayer.Entities.RpgEntities;

namespace RPGTableHelper.DataLayer.Entities.Images;

public class ImageMetaDataEntity : EntityBase<Guid>
{
    [ForeignKey(nameof(CreatedForCampagne))]
    public Guid CreatedForCampagneId { get; set; }

    public virtual CampagneEntity? CreatedForCampagne { get; set; }
    public string ApiKey { get; set; } = default!;

    public bool LocallyStored { get; set; } = default!;

    [ForeignKey(nameof(CreatorUser))]
    public Guid CreatorId { get; set; }
    public virtual UserEntity? CreatorUser { get; set; }

    public ImageType ImageType { get; set; } = default!;
}
